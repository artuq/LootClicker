extends Node

## Schedules inexact local return reminders. Inexact alarms are sufficient for
## 12/24 hour retention nudges and avoid restricted exact-alarm permissions.

signal reminders_enabled_changed(enabled: bool)
signal offline_reward_requested
signal notification_state_changed(state: String)

const PREFERENCES_PATH := "user://engagement_preferences.cfg"
const CHANNEL_ID := "return_rewards"
const NOTIFICATION_TEST_ID := 10001
const NOTIFICATION_12H_ID := 12001
const NOTIFICATION_24H_ID := 24001
const OFFLINE_REWARD_DEEPLINK := "joanaindiana://offline-gold"

var reminders_enabled: bool = true
var notification_state: String = "unavailable"

var _scheduler: NotificationScheduler
var _initialized: bool = false
var _permission_requested: bool = false
var _gameplay_ready: bool = false
var _pending_offline_reward_route: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_preferences()
	if not OS.has_feature("android"):
		_set_state("Local reminders are available in Android builds.")
		return
	if not Engine.has_singleton(NotificationScheduler.PLUGIN_SINGLETON_NAME):
		_set_state("Notification scheduler is not available in this build.")
		return

	_scheduler = NotificationScheduler.new()
	add_child(_scheduler)
	_scheduler.initialization_completed.connect(_on_scheduler_initialized)
	_scheduler.notification_opened.connect(_on_notification_opened)
	_scheduler.post_notifications_permission_granted.connect(_on_permission_granted)
	_scheduler.post_notifications_permission_denied.connect(_on_permission_denied)
	_scheduler.initialize()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		cancel_return_reminders()
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		schedule_return_reminders()


func set_reminders_enabled(enabled: bool) -> void:
	reminders_enabled = enabled
	_save_preferences()
	if not enabled:
		cancel_return_reminders()
	elif _gameplay_ready:
		if (
			_initialized
			and _scheduler != null
			and _permission_requested
			and not _scheduler.has_post_notifications_permission()
		):
			_scheduler.open_app_info_settings()
			_set_state("Enable notifications in Android settings to receive return reminders.")
		else:
			ensure_notification_permission()
	reminders_enabled_changed.emit(enabled)


func on_gameplay_ready() -> void:
	_gameplay_ready = true
	if reminders_enabled:
		ensure_notification_permission()


func ensure_notification_permission() -> void:
	if not reminders_enabled or not _initialized or _scheduler == null:
		return
	if _scheduler.has_post_notifications_permission():
		_set_state("Return reminders enabled.")
		return
	if _permission_requested:
		return
	_permission_requested = true
	_save_preferences()
	_scheduler.request_post_notifications_permission()
	_set_state("Waiting for notification permission.")


func schedule_return_reminders() -> void:
	if (
		not reminders_enabled
		or not _initialized
		or _scheduler == null
		or not _scheduler.has_post_notifications_permission()
		or not FileAccess.file_exists("user://savegame_slot1.json")
	):
		return

	cancel_return_reminders()
	for reminder: Dictionary in get_reminder_definitions():
		var data := (
			NotificationData.new()
			.set_id(int(reminder["id"]))
			.set_channel_id(CHANNEL_ID)
			.set_title(str(reminder["title"]))
			.set_content(str(reminder["content"]))
			.set_small_icon_name("ic_default_notification")
			.set_delay(int(reminder["delay_seconds"]))
			.set_deeplink(OFFLINE_REWARD_DEEPLINK)
			.set_restart_app_option()
		)
		var result := _scheduler.schedule(data)
		if result != OK:
			push_warning("[EngagementManager] Could not schedule reminder %s: %s" % [reminder["id"], result])
	_set_state("Return reminders scheduled for 12 h and 24 h.")


func cancel_return_reminders() -> void:
	if not _initialized or _scheduler == null:
		return
	_scheduler.cancel(NOTIFICATION_12H_ID)
	_scheduler.cancel(NOTIFICATION_24H_ID)


func consume_offline_reward_route() -> bool:
	var pending := _pending_offline_reward_route
	_pending_offline_reward_route = false
	return pending


func _on_scheduler_initialized() -> void:
	_initialized = true
	var channel := (
		NotificationChannel.new()
		.set_id(CHANNEL_ID)
		.set_name("Offline rewards")
		.set_description("Optional reminders when offline gold is ready")
		.set_importance(NotificationChannel.Importance.DEFAULT)
		.set_badge_enabled(false)
	)
	var result := _scheduler.create_notification_channel(channel)
	if not is_channel_creation_success(result):
		push_warning("[EngagementManager] Could not create notification channel: %s" % result)
	var launched_from_id := _scheduler.get_notification_id(NotificationScheduler.DEFAULT_NOTIFICATION_ID)
	if launched_from_id == NOTIFICATION_12H_ID or launched_from_id == NOTIFICATION_24H_ID:
		_mark_offline_reward_route()
	if _gameplay_ready and reminders_enabled:
		ensure_notification_permission()
	elif _scheduler.has_post_notifications_permission():
		_set_state("Return reminders ready.")


func _on_notification_opened(data: NotificationData) -> void:
	if (
		data.get_deeplink() == OFFLINE_REWARD_DEEPLINK
		or data.get_id() == NOTIFICATION_12H_ID
		or data.get_id() == NOTIFICATION_24H_ID
	):
		_mark_offline_reward_route()


static func is_channel_creation_success(result: int) -> bool:
	# Android notification channels are persistent. Recreating one after an app
	# update returns ERR_ALREADY_EXISTS, which is a healthy idempotent outcome.
	return result == OK or result == ERR_ALREADY_EXISTS


func _mark_offline_reward_route() -> void:
	_pending_offline_reward_route = true
	get_tree().set_meta("engagement_deeplink", "offline_gold")
	offline_reward_requested.emit()


func _on_permission_granted(_permission_name: String) -> void:
	_set_state("Return reminders enabled.")


func _on_permission_denied(_permission_name: String) -> void:
	_set_state("Notification permission denied. You can enable it in Android settings.")


func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(PREFERENCES_PATH) != OK:
		return
	reminders_enabled = bool(config.get_value("notifications", "enabled", true))
	_permission_requested = bool(config.get_value("notifications", "permission_requested", false))


func _save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("notifications", "enabled", reminders_enabled)
	config.set_value("notifications", "permission_requested", _permission_requested)
	var error := config.save(PREFERENCES_PATH)
	if error != OK:
		push_warning("[EngagementManager] Could not save reminder preferences: %s" % error)


func _set_state(value: String) -> void:
	notification_state = value
	notification_state_changed.emit(value)


static func get_reminder_definitions() -> Array[Dictionary]:
	return [
		{
			"id": NOTIFICATION_12H_ID,
			"delay_seconds": 12 * 60 * 60,
			"title": "Your gold chest is overflowing!",
			"content": "Come back and claim your offline gold — collect the x2 bonus too.",
		},
		{
			"id": NOTIFICATION_24H_ID,
			"delay_seconds": 24 * 60 * 60,
			"title": "Joana's crew needs you!",
			"content": "Your offline gold chest is full. Return and collect it now.",
		},
	]
