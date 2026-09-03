extends Node

# --- PLATFORM CONFIG ---
var is_web: bool = false
var is_android: bool = false
var is_poki: bool = false
var is_crazygames: bool = false

# --- ADMOB CONSTANTS & VARIABLES (copied from GameBattleManager.gd) ---
const REWARDED_AD_UNIT_ID = "ca-app-pub-4067533100503154/9484519330"
const BANNER_AD_UNIT_ID = "ca-app-pub-4067533100503154/1590900646"
const INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-4067533100503154/7266733306"
const TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
const TEST_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
const TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"

var _admob_available: bool = false
var _admob_started: bool = false
var _admob_initializing: bool = false
var _ump_form_shown: bool = false
var _rewarded_ad = null # Untyped to prevent compiler errors if class not present on some exports
var _rewarded_loading: bool = false
var _interstitial_ad = null
var _banner_ad = null
var _banner_should_be_visible: bool = false
var _rewarded_ad_load_time: float = 0.0
var _interstitial_ad_load_time: float = 0.0
var _kills_since_interstitial: int = 0
# Min time between interstitials — kill cadence alone spams ads on fast early stages.
const INTERSTITIAL_MIN_INTERVAL_SEC := 45.0
var _last_interstitial_time: float = 0.0

# AdMob references to prevent GC
var _admob_init_listener
var _rewarded_loader
var _rewarded_callback
var _reward_listener
var _content_callback
var _banner_listener
var _interstitial_loader
var _interstitial_callback
var _interstitial_content_callback
var _was_tree_paused_before_ad: bool = false

func _pause_game_for_ad():
	_was_tree_paused_before_ad = get_tree().paused
	get_tree().paused = true

func _resume_game_after_ad():
	if not _was_tree_paused_before_ad:
		get_tree().paused = false

# --- WEB SDK INTEGRATION ---
var window = null
# JS callbacks to handle async responses from JS side
var _js_ad_started_cb
var _js_ad_finished_cb
var _js_ad_error_cb
var _js_poki_commercial_cb
var _js_poki_rewarded_cb

# Callables to store game success/fail closures
var _current_success_cb: Callable
var _current_fail_cb: Callable
var _current_reward_placement: String = "rewarded"
var _web_ad_is_rewarded: bool = false

# --- SIGNAL FOR UI UPDATE ---
signal ad_status_changed

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	is_web = OS.has_feature("web")
	is_android = OS.has_feature("android") or OS.has_feature("ios")
	var purchases := get_node_or_null("/root/PurchaseManager")
	if purchases and not purchases.entitlement_changed.is_connected(_on_remove_ads_entitlement_changed):
		purchases.entitlement_changed.connect(_on_remove_ads_entitlement_changed)
	
	if is_web:
		_init_web_sdk()
		# Prevent stretching to landscape by enforcing 9:16 aspect ratio with black bars
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	elif is_android and not has_ad_free_entitlement():
		_init_admob()
	elif is_android:
		print("[PlatformManager/AdMob] Remove Ads active — skipping ad SDK requests.")
	else:
		print("[PlatformManager] Desktop/Editor platform detected. Using simulated ads.")

# ============================================================
# === ADMOB SYSTEM (INTEGRATION FROM GAMEBATTLEMANAGER) ===
# ============================================================

func _init_admob():
	if _admob_started or _admob_initializing or has_ad_free_entitlement():
		return
	_admob_initializing = true
	print("[PlatformManager/AdMob] Starting UMP consent flow...")
	_request_ump_consent()

func _request_ump_consent():
	# Poing AdMob exposes GDScript global classes (ConsentRequestParameters,
	# UserMessagingPlatform, MobileAds, ...), NOT native ClassDB types — must call
	# them directly, not via ClassDB.instantiate/Engine.get_singleton.
	var params := ConsentRequestParameters.new()
	UserMessagingPlatform.consent_information.update(
		params,
		_on_ump_success,
		_on_ump_failure
	)

func _on_ump_success():
	if has_ad_free_entitlement():
		_admob_initializing = false
		return
	var status = UserMessagingPlatform.consent_information.get_consent_status()
	print("[PlatformManager/AdMob] UMP Consent status: %d" % status)
	
	if status == ConsentInformation.ConsentStatus.REQUIRED:
		if UserMessagingPlatform.consent_information.get_is_consent_form_available():
			UserMessagingPlatform.load_consent_form(_on_ump_form_loaded, func(e): _start_admob())
			# Watchdog: only if the form never appeared (load callback stalled).
			# Must NOT fire while the user is reading the consent form — starting
			# the SDK before consent = limited ads in EEA + UMP policy risk.
			await get_tree().create_timer(6.0).timeout
			if not _admob_started and not _ump_form_shown:
				print("[PlatformManager/AdMob] Form never appeared — watchdog starting SDK")
				_start_admob()
			elif not _admob_started:
				# Form is visible — give the user time; hard cap so a lost
				# dismiss-callback can't kill ads for the whole session
				await get_tree().create_timer(120.0).timeout
				if not _admob_started:
					print("[PlatformManager/AdMob] Form dismiss callback lost — watchdog starting SDK")
					_start_admob()
			return
	_start_admob()

func _on_ump_failure(error):
	print("[PlatformManager/AdMob] UMP update failed [%d]: %s — proceeding anyway" % [error.error_code, error.message])
	_start_admob()

func _on_ump_form_loaded(form):
	if has_ad_free_entitlement():
		_admob_initializing = false
		return
	_ump_form_shown = true
	form.show(func(error):
		_ump_form_shown = false
		if error:
			print("[PlatformManager/AdMob] Form error [%d]: %s" % [error.error_code, error.message])
		else:
			print("[PlatformManager/AdMob] Consent form dismissed — continuing SDK startup")
		# UMP calls this callback both after a normal dismissal and after an
		# error. Always continue: previously the successful path left AdMob
		# uninitialized for up to two minutes.
		_start_admob()
	)

func _start_admob():
	if _admob_started or has_ad_free_entitlement():
		_admob_initializing = false
		return
	_admob_initializing = false
	_admob_started = true
	print("[PlatformManager/AdMob] Initializing SDK...")
	
	var cfg := RequestConfiguration.new()
	cfg.max_ad_content_rating = "PG" # RequestConfiguration.MAX_AD_CONTENT_RATING_PG
	cfg.tag_for_child_directed_treatment = 0 # TagForChildDirectedTreatment.FALSE
	cfg.tag_for_under_age_of_consent = 0 # TagForUnderAgeOfConsent.FALSE
	if OS.is_debug_build():
		# Add standard Android emulator test device ID to prevent invalid traffic in dev
		cfg.test_device_ids = ["B3EEABB8EE11C2BE770B684D95219ECB"]
	else:
		cfg.test_device_ids = []
	MobileAds.set_request_configuration(cfg)

	_admob_init_listener = OnInitializationCompleteListener.new()
	_admob_init_listener.on_initialization_complete = func(_s):
		_admob_available = true
		print("[PlatformManager/AdMob] SDK ready")
		ad_status_changed.emit()
		if not has_ad_free_entitlement():
			_init_banner_ad()
			_preload_rewarded_ad()
			_preload_interstitial_ad()
	MobileAds.initialize(_admob_init_listener)

# ---- REWARDED AD ----
func _preload_rewarded_ad():
	if has_ad_free_entitlement() or not _admob_available or _rewarded_ad != null or _rewarded_loading:
		return
	_rewarded_loading = true
	print("[PlatformManager/AdMob] Preloading rewarded ad...")
	
	_rewarded_callback = RewardedAdLoadCallback.new()
	_rewarded_callback.on_ad_loaded = func(ad):
		_rewarded_loading = false
		if has_ad_free_entitlement():
			ad.destroy()
			ad_status_changed.emit()
			return
		_rewarded_ad = ad
		_rewarded_ad_load_time = Time.get_unix_time_from_system()
		print("[PlatformManager/AdMob] Rewarded READY")
		ad_status_changed.emit()
	_rewarded_callback.on_ad_failed_to_load = func(err):
		_rewarded_loading = false
		print("[PlatformManager/AdMob] Rewarded failed to load: %d" % err.code)
		_rewarded_ad = null
		ad_status_changed.emit()
		await get_tree().create_timer(5.0).timeout
		_preload_rewarded_ad()
			
	_rewarded_loader = RewardedAdLoader.new()
	_rewarded_loader.load(_rewarded_ad_unit_id(), AdRequest.new(), _rewarded_callback)

# ---- BANNER AD ----
func _init_banner_ad():
	var unit_id := _banner_ad_unit_id()
	if not _admob_available or unit_id.is_empty() or not are_forced_ads_enabled():
		return
	# AdView constructor takes (unit_id, AdSize, AdPosition.Values)
	_banner_ad = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.TOP)

	_banner_listener = AdListener.new()
	_banner_listener.on_ad_loaded = func():
		print("[PlatformManager/AdMob] Banner loaded")
		# Banners are shown contextually via show_banner() / hide_banner()
	_banner_listener.on_ad_impression = func():
		print("[PlatformManager/AdMob] Banner IMPRESSION recorded")
	_banner_listener.on_ad_failed_to_load = func(err):
		print("[PlatformManager/AdMob] Banner failed to load: %d" % err.code)
		await get_tree().create_timer(30.0).timeout
		if _admob_available and _banner_ad:
			_banner_ad.load_ad(AdRequest.new())

	_banner_ad.ad_listener = _banner_listener
	_banner_ad.load_ad(AdRequest.new())
	if _banner_should_be_visible:
		_banner_ad.show()
	else:
		_banner_ad.hide()

func show_banner():
	if not are_forced_ads_enabled():
		_banner_should_be_visible = false
		return
	_banner_should_be_visible = true
	if _banner_ad:
		_banner_ad.show()
		print("[PlatformManager/AdMob] Banner SHOW requested")
	else:
		print("[PlatformManager/AdMob] Banner queued until SDK is ready")

func hide_banner():
	_banner_should_be_visible = false
	if _banner_ad:
		_banner_ad.hide()

# ---- INTERSTITIAL AD ----
func _preload_interstitial_ad():
	var unit_id := _interstitial_ad_unit_id()
	if (
		not _admob_available
		or unit_id.is_empty()
		or _interstitial_ad != null
		or not are_forced_ads_enabled()
	):
		return
	print("[PlatformManager/AdMob] Preloading interstitial ad...")
	
	_interstitial_callback = InterstitialAdLoadCallback.new()
	_interstitial_callback.on_ad_loaded = func(ad):
		if not are_forced_ads_enabled():
			ad.destroy()
			return
		print("[PlatformManager/AdMob] Interstitial READY")
		_interstitial_ad_load_time = Time.get_unix_time_from_system()
		_interstitial_content_callback = FullScreenContentCallback.new()
		_interstitial_content_callback.on_ad_showed_full_screen_content = func():
			print("[PlatformManager/AdMob] Interstitial SHOWED on screen")
			_pause_game_for_ad()
		_interstitial_content_callback.on_ad_impression = func():
			print("[PlatformManager/AdMob] Interstitial IMPRESSION recorded")
		_interstitial_content_callback.on_ad_dismissed_full_screen_content = func():
			_resume_game_after_ad()
			if _interstitial_ad:
				_interstitial_ad.destroy()
				_interstitial_ad = null
			_preload_interstitial_ad()
		_interstitial_content_callback.on_ad_failed_to_show_full_screen_content = func(err):
			print("[PlatformManager/AdMob] Interstitial show failed: %s" % str(err))
			_resume_game_after_ad()
			if _interstitial_ad:
				_interstitial_ad.destroy()
				_interstitial_ad = null
			_preload_interstitial_ad()
		ad.full_screen_content_callback = _interstitial_content_callback
		_interstitial_ad = ad
	_interstitial_callback.on_ad_failed_to_load = func(err):
		print("[PlatformManager/AdMob] Interstitial failed: %d" % err.code)
		_interstitial_ad = null
		await get_tree().create_timer(30.0).timeout
		_preload_interstitial_ad()
			
	_interstitial_loader = InterstitialAdLoader.new()
	_interstitial_loader.load(unit_id, AdRequest.new(), _interstitial_callback)

func show_interstitial():
	if not are_forced_ads_enabled():
		return false
	if _admob_available and _interstitial_ad:
		if Time.get_unix_time_from_system() - _interstitial_ad_load_time > 3600.0:
			print("[PlatformManager/AdMob] Interstitial expired (older than 1h), dropping")
			_interstitial_ad.destroy()
			_interstitial_ad = null
			return false
		print("[PlatformManager/AdMob] Showing interstitial")
		_interstitial_ad.show()
		return true
	return false

# ============================================================
# === WEB SDK SYSTEM (CRAZYGAMES & POKI) ===
# ============================================================

func _init_web_sdk():
	window = JavaScriptBridge.get_interface("window")
	if not window:
		print("[PlatformManager/Web] JavaScript window interface not available")
		return
		
	# Setup JavaScript callbacks
	_js_ad_started_cb = JavaScriptBridge.create_callback(_on_web_ad_started)
	_js_ad_finished_cb = JavaScriptBridge.create_callback(_on_web_ad_finished)
	_js_ad_error_cb = JavaScriptBridge.create_callback(_on_web_ad_error)
	
	_js_poki_commercial_cb = JavaScriptBridge.create_callback(_on_poki_commercial_break_complete)
	_js_poki_rewarded_cb = JavaScriptBridge.create_callback(_on_poki_rewarded_break_complete)

	# Detect platform portal
	if window.get("CrazyGames") != null:
		is_crazygames = true
		print("[PlatformManager/Web] Detected CrazyGames environment")
	elif window.get("PokiSDK") != null:
		is_poki = true
		print("[PlatformManager/Web] Detected Poki environment")
	else:
		# Fallback hostname check
		var location = window.get("location")
		if location:
			var hostname = str(location.get("hostname"))
			if "poki" in hostname:
				is_poki = true
				print("[PlatformManager/Web] Detected Poki environment via hostname: %s" % hostname)
			elif "crazygames" in hostname or "crazy" in hostname:
				is_crazygames = true
				print("[PlatformManager/Web] Detected CrazyGames environment via hostname: %s" % hostname)
			else:
				print("[PlatformManager/Web] Generic Web host: %s. Using mock ads." % hostname)

	# Initialize SDK if Poki is active
	if is_poki:
		_init_poki_sdk_js()


func _init_poki_sdk_js():
	# Poki is initialized in index.html, but let's check it
	print("[PlatformManager/Web] Poki SDK connected")

# --- WEB CYCLE & EVENTS ---
func gameplay_start():
	if not is_web or not window: return
	
	if is_poki and window.get("PokiSDK") != null:
		window.PokiSDK.gameplayStart()
		print("[PlatformManager/Web] Poki gameplayStart()")
	elif is_crazygames and window.get("CrazyGames") != null:
		var sdk = window.CrazyGames.get("SDK")
		if sdk and sdk.get("game") != null:
			sdk.game.gameplayStart()
			print("[PlatformManager/Web] CrazyGames gameplayStart()")

func gameplay_stop():
	if not is_web or not window: return
	
	if is_poki and window.get("PokiSDK") != null:
		window.PokiSDK.gameplayStop()
		print("[PlatformManager/Web] Poki gameplayStop()")
	elif is_crazygames and window.get("CrazyGames") != null:
		var sdk = window.CrazyGames.get("SDK")
		if sdk and sdk.get("game") != null:
			sdk.game.gameplayStop()
			print("[PlatformManager/Web] CrazyGames gameplayStop()")

func happy_time():
	if is_crazygames and window and window.get("CrazyGames") != null:
		var sdk = window.CrazyGames.get("SDK")
		if sdk and sdk.get("game") != null:
			sdk.game.happytime()
			print("[PlatformManager/Web] CrazyGames happytime()")

# --- WEB ADS CALLS ---
func show_web_rewarded_ad(on_success: Callable, on_fail: Callable):
	_current_success_cb = on_success
	_current_fail_cb = on_fail
	_web_ad_is_rewarded = true
	
	if is_poki and window.get("PokiSDK") != null:
		print("[PlatformManager/Web] Requesting Poki rewarded ad...")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		get_tree().paused = true
		window.PokiSDK.rewardedBreak(_js_poki_rewarded_cb)
		
	elif is_crazygames and window.get("CrazyGames") != null:
		print("[PlatformManager/Web] Requesting CrazyGames rewarded ad...")
		var sdk = window.CrazyGames.get("SDK")
		if sdk and sdk.get("ad") != null:
			var callbacks = JavaScriptBridge.create_object("Object")
			callbacks["adStarted"] = _js_ad_started_cb
			callbacks["adFinished"] = _js_ad_finished_cb
			callbacks["adError"] = _js_ad_error_cb
			sdk.ad.requestAd("rewarded", callbacks)
		else:
			_run_mock_rewarded(on_success, on_fail)
	else:
		_run_mock_rewarded(on_success, on_fail)

func show_web_interstitial_ad():
	_web_ad_is_rewarded = false
	if is_poki and window.get("PokiSDK") != null:
		print("[PlatformManager/Web] Requesting Poki interstitial...")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		get_tree().paused = true
		window.PokiSDK.commercialBreak(_js_poki_commercial_cb)
		return true
		
	elif is_crazygames and window.get("CrazyGames") != null:
		print("[PlatformManager/Web] Requesting CrazyGames interstitial...")
		var sdk = window.CrazyGames.get("SDK")
		if sdk and sdk.get("ad") != null:
			var callbacks = JavaScriptBridge.create_object("Object")
			callbacks["adStarted"] = _js_ad_started_cb
			callbacks["adFinished"] = _js_ad_finished_cb
			callbacks["adError"] = _js_ad_error_cb
			sdk.ad.requestAd("midgame", callbacks)
			return true
	return false

# --- JS CALLBACKS RECEIVED ---

# Poki Commercial Callback
func _on_poki_commercial_break_complete(_args):
	print("[PlatformManager/Web] Poki commercialBreak completed")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().paused = false

# Poki Rewarded Callback
func _on_poki_rewarded_break_complete(args):
	var success = false
	if args and args.size() > 0:
		success = bool(args[0])
	print("[PlatformManager/Web] Poki rewardedBreak completed: success = ", success)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().paused = false
	if success:
		_record_rewarded_ad(_current_reward_placement)
		if _current_success_cb.is_valid():
			_current_success_cb.call()
	else:
		if _current_fail_cb.is_valid():
			_current_fail_cb.call()
	_web_ad_is_rewarded = false

# CrazyGames SDK callbacks
func _on_web_ad_started(_args):
	print("[PlatformManager/Web] CrazyGames Ad started playing")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	get_tree().paused = true

func _on_web_ad_finished(_args):
	print("[PlatformManager/Web] CrazyGames Ad finished playing")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().paused = false
	if _web_ad_is_rewarded:
		_record_rewarded_ad(_current_reward_placement)
	if _web_ad_is_rewarded and _current_success_cb.is_valid():
		_current_success_cb.call()
	_web_ad_is_rewarded = false

func _on_web_ad_error(args):
	print("[PlatformManager/Web] CrazyGames Ad error: ", args)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().paused = false
	if _current_fail_cb.is_valid():
		_current_fail_cb.call()
	_web_ad_is_rewarded = false

# ============================================================
# === PUBLIC API FOR THE GAME (UNIFIED ENTRY POINT) ===
# ============================================================

func is_ad_available() -> bool:
	if has_ad_free_entitlement():
		return false
	if is_android:
		if _admob_available and _rewarded_ad != null:
			if Time.get_unix_time_from_system() - _rewarded_ad_load_time > 3600.0:
				print("[PlatformManager/AdMob] Rewarded expired (older than 1h), dropping")
				_rewarded_ad.destroy()
				_rewarded_ad = null
				return false
			return true
		return false
	elif is_web:
		# Web ads are requested on-demand directly, we assume SDK is loaded
		return is_poki or is_crazygames or window != null
	else:
		# Mock ads in editor
		return true

func is_reward_available() -> bool:
	# Remove Ads owners keep gameplay bonuses, but receive them without an ad.
	return has_ad_free_entitlement() or is_ad_available()

func preload_rewarded_ad_now():
	if is_android and _admob_available and not has_ad_free_entitlement():
		if _rewarded_ad != null:
			if Time.get_unix_time_from_system() - _rewarded_ad_load_time > 3600.0:
				_rewarded_ad.destroy()
				_rewarded_ad = null
			else:
				return # valid ad already loaded
		_preload_rewarded_ad()

func preload_interstitial_ad_now():
	if is_android and _admob_available and are_forced_ads_enabled():
		if _interstitial_ad != null:
			if Time.get_unix_time_from_system() - _interstitial_ad_load_time > 3600.0:
				_interstitial_ad.destroy()
				_interstitial_ad = null
			else:
				return
		_preload_interstitial_ad()

func request_rewarded_ad(reward_description: String, on_success: Callable, on_fail: Callable, parent_node: Node = null):
	_current_reward_placement = _normalize_reward_placement(reward_description)
	if has_ad_free_entitlement():
		print("[PlatformManager] Remove Ads active — granting reward without an ad.")
		on_success.call()
		return
	if is_android:
		if _admob_available and _rewarded_ad != null:
			_show_admob_rewarded(_current_reward_placement, on_success, on_fail)
		else:
			print("[PlatformManager/AdMob] Rewarded ad requested but not ready yet. Fetching immediately...")
			if not _rewarded_loading:
				_preload_rewarded_ad()
			var wait_time: float = 0.0
			while (_rewarded_ad == null or _rewarded_loading) and wait_time < 5.0:
				await get_tree().create_timer(0.2).timeout
				wait_time += 0.2
			if _rewarded_ad != null:
				_show_admob_rewarded(_current_reward_placement, on_success, on_fail)
			else:
				print("[PlatformManager/AdMob] Rewarded ad fetch timeout — failing request.")
				on_fail.call()
	elif is_web:
		show_web_rewarded_ad(on_success, on_fail)
	else:
		# Desktop mock ad
		_run_mock_rewarded(on_success, on_fail, parent_node)

func request_interstitial_ad():
	if is_android and not are_forced_ads_enabled():
		return
	if is_android:
		_kills_since_interstitial += 1
		var since_last := Time.get_unix_time_from_system() - _last_interstitial_time
		
		# Pre-load ahead of time at 5+ kills so it is ready for kill 8
		if _kills_since_interstitial >= 5:
			preload_interstitial_ad_now()
			
		# Both gates: kill cadence (8) AND min time interval (45s)
		if _kills_since_interstitial >= 8 and since_last >= INTERSTITIAL_MIN_INTERVAL_SEC:
			if show_interstitial():
				_last_interstitial_time = Time.get_unix_time_from_system()
				_kills_since_interstitial = 0
			else:
				# Trigger reached but not loaded, retry next kill
				_kills_since_interstitial = 7
				preload_interstitial_ad_now()
	elif is_web:
		show_web_interstitial_ad()

# --- INTERNAL HELPERS ---

func _rewarded_ad_unit_id() -> String:
	return TEST_REWARDED_AD_UNIT_ID if OS.is_debug_build() else REWARDED_AD_UNIT_ID


func _banner_ad_unit_id() -> String:
	return TEST_BANNER_AD_UNIT_ID if OS.is_debug_build() else BANNER_AD_UNIT_ID


func _interstitial_ad_unit_id() -> String:
	return TEST_INTERSTITIAL_AD_UNIT_ID if OS.is_debug_build() else INTERSTITIAL_AD_UNIT_ID

func _show_admob_rewarded(placement: String, on_success: Callable, on_fail: Callable):
	if has_ad_free_entitlement():
		if _rewarded_ad:
			_rewarded_ad.destroy()
			_rewarded_ad = null
		on_success.call()
		return
	var _reward_earned = [false] # using array to capture by reference in lambdas
	_reward_listener = OnUserEarnedRewardListener.new()
	_reward_listener.on_user_earned_reward = func(_r):
		_reward_earned[0] = true
		_record_rewarded_ad(placement)
		print("[PlatformManager/AdMob] Rewarded EARNED by user (reward will be granted on dismiss)")
	_content_callback = FullScreenContentCallback.new()
	_content_callback.on_ad_showed_full_screen_content = func():
		print("[PlatformManager/AdMob] Rewarded SHOWED on screen")
		_pause_game_for_ad()
	_content_callback.on_ad_impression = func():
		print("[PlatformManager/AdMob] Rewarded IMPRESSION recorded")
	_content_callback.on_ad_dismissed_full_screen_content = func():
		_resume_game_after_ad()
		if _rewarded_ad:
			_rewarded_ad.destroy()
		_rewarded_ad = null
		_rewarded_loading = false
		if _reward_earned[0]:
			print("[PlatformManager/AdMob] Rewarded dismissed with reward earned — executing on_success!")
			on_success.call()
		else:
			print("[PlatformManager/AdMob] Rewarded dismissed without earning reward")
			on_fail.call()
		ad_status_changed.emit()
		_preload_rewarded_ad()
	_content_callback.on_ad_failed_to_show_full_screen_content = func(err):
		print("[PlatformManager/AdMob] Rewarded show failed: %s" % str(err))
		_resume_game_after_ad()
		if _rewarded_ad:
			_rewarded_ad.destroy()
		_rewarded_ad = null
		_rewarded_loading = false
		on_fail.call()
		ad_status_changed.emit()
		_preload_rewarded_ad()
	_rewarded_ad.full_screen_content_callback = _content_callback
	_rewarded_ad.show(_reward_listener)

func _run_mock_rewarded(on_success: Callable, on_fail: Callable, parent_node: Node = null):
	print("[PlatformManager/Mock] Ads unavailable or blocked. Granting reward automatically.")
	on_success.call()

func are_forced_ads_enabled() -> bool:
	return are_ads_enabled()

func are_ads_enabled() -> bool:
	var purchases := get_node_or_null("/root/PurchaseManager")
	var owns_remove_ads: bool = purchases != null and bool(purchases.has_remove_ads())
	return should_show_ads(is_android, owns_remove_ads)

func has_ad_free_entitlement() -> bool:
	var purchases := get_node_or_null("/root/PurchaseManager")
	var owns_remove_ads: bool = purchases != null and bool(purchases.has_remove_ads())
	return should_grant_reward_without_ad(is_android, owns_remove_ads)

static func should_grant_reward_without_ad(android_platform: bool, owns_remove_ads: bool) -> bool:
	return android_platform and owns_remove_ads

static func should_show_ads(android_platform: bool, owns_remove_ads: bool) -> bool:
	return not android_platform or not owns_remove_ads

static func should_show_forced_ads(android_platform: bool, owns_remove_ads: bool) -> bool:
	return should_show_ads(android_platform, owns_remove_ads)

func _on_remove_ads_entitlement_changed(owned: bool) -> void:
	if owned:
		_banner_should_be_visible = false
		_rewarded_loading = false
		if _rewarded_ad:
			_rewarded_ad.destroy()
			_rewarded_ad = null
		if _banner_ad:
			_banner_ad.hide()
			_banner_ad.destroy()
			_banner_ad = null
		if _interstitial_ad:
			_interstitial_ad.destroy()
			_interstitial_ad = null
	else:
		if is_android and not _admob_started:
			_init_admob()
		elif _admob_available and _banner_ad == null:
			_init_banner_ad()
	ad_status_changed.emit()

func _record_rewarded_ad(placement: String) -> void:
	var analytics := get_node_or_null("/root/AnalyticsManager")
	if analytics:
		analytics.log_ad_watched(placement)

func _normalize_reward_placement(description: String) -> String:
	var normalized := description.to_lower()
	if "offline" in normalized or "gold" in normalized:
		return "offline_gold_x2"
	if "revive" in normalized or "continue" in normalized:
		return "revive"
	if "heal" in normalized or "hp" in normalized:
		return "full_heal"
	return "rewarded"
