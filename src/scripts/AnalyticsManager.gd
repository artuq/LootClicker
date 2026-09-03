extends Node

## Firebase collection is disabled in the Android manifest. It is enabled only
## after the player explicitly opts in from Settings.

signal consent_changed(granted: bool)
signal analytics_state_changed(state: String)

const PREFERENCES_PATH := "user://privacy_preferences.cfg"
const MAX_QUEUED_EVENTS := 32

const EVENT_BOSS_DEFEATED := "boss_defeated"
const EVENT_AD_WATCHED := "ad_watched"
const EVENT_SESSION_LENGTH := "session_length"

var analytics_consent: bool = true
var has_consent_decision: bool = false
var analytics_state: String = "disabled"

var _firebase_core: Object
var _firebase_analytics: Object
var _native_ready: bool = false
var _queued_events: Array[Dictionary] = []
var _debug_events: Array[Dictionary] = []
var _session_started_msec: int = 0
var _session_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_preferences()
	_start_session()

	if not OS.has_feature("android"):
		_set_state("Firebase Analytics is available in Android builds.")
		return
	if not Engine.has_singleton("GodotxFirebaseCore") or not Engine.has_singleton("GodotxFirebaseAnalytics"):
		_set_state("Firebase plugin is not available in this build.")
		return

	_firebase_core = Engine.get_singleton("GodotxFirebaseCore")
	_firebase_analytics = Engine.get_singleton("GodotxFirebaseAnalytics")
	_firebase_core.core_initialized.connect(_on_core_initialized)
	_firebase_analytics.analytics_initialized.connect(_on_analytics_initialized)
	_set_state("Initializing Firebase…")
	_firebase_core.initialize()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_finish_session()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_start_session()


func set_collection_consent(granted: bool) -> void:
	analytics_consent = granted
	has_consent_decision = true
	_save_preferences()
	_apply_native_consent()
	if granted:
		_flush_events()
	else:
		_queued_events.clear()
	consent_changed.emit(granted)


func log_boss_defeated(stage: int) -> bool:
	return log_event(EVENT_BOSS_DEFEATED, {"stage": stage})


func log_ad_watched(placement: String) -> bool:
	return log_event(EVENT_AD_WATCHED, {"placement": normalize_ad_placement(placement)})


func log_event(event_name: String, parameters: Dictionary = {}) -> bool:
	if not analytics_consent:
		return false
	var event := {"name": event_name, "parameters": parameters.duplicate(true)}
	_debug_events.append(event)
	if _debug_events.size() > 64:
		_debug_events.pop_front()

	if _native_ready:
		_firebase_analytics.log_event(event_name, parameters)
	else:
		_queued_events.append(event)
		if _queued_events.size() > MAX_QUEUED_EVENTS:
			_queued_events.pop_front()
	return true


func get_debug_events() -> Array[Dictionary]:
	return _debug_events.duplicate(true)


func _on_core_initialized(success: bool) -> void:
	if not success:
		_set_state("Firebase is not configured. Add google-services.json for this app.")
		return
	_set_state("Firebase Core ready.")
	_firebase_analytics.initialize()


func _on_analytics_initialized(success: bool) -> void:
	_native_ready = success
	if not success:
		_set_state("Firebase Analytics initialization failed.")
		return
	_apply_native_consent()
	_set_state("Analytics enabled." if analytics_consent else "Analytics disabled until consent.")
	_flush_events()


func _apply_native_consent() -> void:
	if not _native_ready or _firebase_analytics == null:
		return
	var analytics_storage := "granted" if analytics_consent else "denied"
	_firebase_analytics.set_consent({
		"analytics_storage": analytics_storage,
		"ad_storage": "denied",
		"ad_user_data": "denied",
		"ad_personalization": "denied",
	})
	_firebase_analytics.set_analytics_collection_enabled(analytics_consent)


func _flush_events() -> void:
	if not analytics_consent or not _native_ready:
		return
	for event: Dictionary in _queued_events:
		_firebase_analytics.log_event(str(event["name"]), event["parameters"])
	_queued_events.clear()


func _start_session() -> void:
	if _session_active:
		return
	_session_started_msec = Time.get_ticks_msec()
	_session_active = true


func _finish_session() -> void:
	if not _session_active:
		return
	var duration_seconds := maxi(1, int((Time.get_ticks_msec() - _session_started_msec) / 1000.0))
	_session_active = false
	if not analytics_consent:
		return
	var event := {"name": EVENT_SESSION_LENGTH, "parameters": {"duration_seconds": duration_seconds}}
	_debug_events.append(event)
	if _debug_events.size() > 64:
		_debug_events.pop_front()
	if _native_ready and _firebase_analytics != null:
		_firebase_analytics.call_deferred("log_event", EVENT_SESSION_LENGTH, {"duration_seconds": duration_seconds})
	else:
		_queued_events.append(event)


func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(PREFERENCES_PATH) != OK:
		return
	has_consent_decision = bool(config.get_value("analytics", "decision_made", false))
	analytics_consent = bool(config.get_value("analytics", "enabled", true))


func _save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("analytics", "decision_made", has_consent_decision)
	config.set_value("analytics", "enabled", analytics_consent)
	var error := config.save(PREFERENCES_PATH)
	if error != OK:
		push_warning("[AnalyticsManager] Could not save privacy preference: %s" % error)


func _set_state(value: String) -> void:
	analytics_state = value
	analytics_state_changed.emit(value)


static func normalize_ad_placement(value: String) -> String:
	var normalized := value.to_lower()
	if "offline" in normalized or "gold" in normalized:
		return "offline_gold_x2"
	if "revive" in normalized or "continue" in normalized:
		return "revive"
	if "heal" in normalized or "hp" in normalized:
		return "full_heal"
	return "rewarded"
