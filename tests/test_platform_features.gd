extends SceneTree

## Lightweight deterministic regression suite, matching the test style used in
## the Water Sort project. Native Google SDKs are covered by release-build and
## manifest checks; their state machines are exercised here with fake responses.

const PURCHASE_SCRIPT := preload("res://src/scripts/PurchaseManager.gd")
const ANALYTICS_SCRIPT := preload("res://src/scripts/AnalyticsManager.gd")
const ENGAGEMENT_SCRIPT := preload("res://src/scripts/EngagementManager.gd")
const PLATFORM_SCRIPT := preload("res://src/scripts/PlatformManager.gd")

var _checks: int = 0
var _failures: int = 0
const EXPECTED_CHECKS := 66


func _initialize() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	_test_remove_ads_purchase_contract()
	_test_remove_ads_price_contract()
	_test_all_ad_gate()
	_test_analytics_consent_and_event_contract()
	_test_notification_contract()
	_test_android_release_configuration()
	if _checks != EXPECTED_CHECKS:
		_failures += 1
		push_error("Test run was interrupted: expected %d checks, ran %d" % [EXPECTED_CHECKS, _checks])

	if _failures == 0:
		print("PASS: %d platform feature checks" % _checks)
		quit(0)
	else:
		push_error("FAIL: %d of %d platform feature checks" % [_failures, _checks])
		quit(1)


func _test_remove_ads_purchase_contract() -> void:
	var purchased := [{
		"product_ids": [PURCHASE_SCRIPT.REMOVE_ADS_PRODUCT_ID],
		"purchase_state": BillingClient.PurchaseState.PURCHASED,
		"purchase_token": "test-token",
		"is_acknowledged": false,
	}]
	var pending := [{
		"product_ids": PackedStringArray([PURCHASE_SCRIPT.REMOVE_ADS_PRODUCT_ID]),
		"purchase_state": BillingClient.PurchaseState.PENDING,
	}]
	var unrelated := [{
		"product_ids": ["coins_small"],
		"purchase_state": BillingClient.PurchaseState.PURCHASED,
	}]

	_expect(PURCHASE_SCRIPT.REMOVE_ADS_PRODUCT_ID == "remove_ads_lifetime", "stable Play product ID")
	_expect(PURCHASE_SCRIPT.REMOVE_ADS_PURCHASE_OPTION_ID == "standard", "stable Play purchase option ID")
	_expect(PURCHASE_SCRIPT.purchase_snapshot_owns_remove_ads(purchased), "completed purchase grants entitlement")
	_expect(not PURCHASE_SCRIPT.purchase_snapshot_owns_remove_ads(pending), "pending purchase grants nothing")
	_expect(not PURCHASE_SCRIPT.purchase_snapshot_owns_remove_ads(unrelated), "unrelated purchase grants nothing")
	_expect(not PURCHASE_SCRIPT.purchase_snapshot_owns_remove_ads([]), "empty authoritative snapshot grants nothing")


func _test_remove_ads_price_contract() -> void:
	var current_schema := {
		"one_time_purchase_offer_details_list": [
			{
				"purchase_option_id": "promo",
				"offer_id": "launch",
				"formatted_price": "4,99 zł",
			},
			{
				"purchase_option_id": "standard",
				"offer_id": null,
				"formatted_price": "12,99 zł",
			},
		]
	}
	var direct := {"one_time_purchase_offer_details": {"formatted_price": "9,99 zł"}}
	var keyed := {
		"one_time_purchase_offer_details": {
			PURCHASE_SCRIPT.REMOVE_ADS_PRODUCT_ID: {"formatted_price": "$2.99"}
		}
	}
	_expect(PURCHASE_SCRIPT._extract_formatted_price(current_schema) == "12,99 zł", "Billing 3.3 localized price")
	_expect(PURCHASE_SCRIPT._extract_formatted_price(direct) == "9,99 zł", "legacy direct localized price")
	_expect(PURCHASE_SCRIPT._extract_formatted_price(keyed) == "$2.99", "keyed localized price")
	_expect(PURCHASE_SCRIPT._extract_formatted_price({}) == "", "missing price is not invented")


func _test_all_ad_gate() -> void:
	_expect(PLATFORM_SCRIPT.should_show_ads(true, false), "Android free player can receive ads")
	_expect(not PLATFORM_SCRIPT.should_show_ads(true, true), "Android owner receives no ad format")
	_expect(PLATFORM_SCRIPT.should_show_ads(false, true), "Play entitlement does not alter web monetization")
	_expect(not PLATFORM_SCRIPT.should_show_forced_ads(true, true), "legacy forced-ad callers use the same entitlement")
	_expect(PLATFORM_SCRIPT.should_grant_reward_without_ad(true, true), "Android owner receives rewarded bonuses without video")
	_expect(not PLATFORM_SCRIPT.should_grant_reward_without_ad(true, false), "Android free player still uses rewarded video")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "granting reward without an ad", "rewarded requests have an ad-free owner path")
	_expect_file_contains("res://src/scenes/StoreScene.gd", "rewarded videos", "Store explicitly includes rewarded videos")


func _test_analytics_consent_and_event_contract() -> void:
	var analytics = ANALYTICS_SCRIPT.new()
	_expect(not analytics.log_boss_defeated(1), "event rejected before analytics consent")
	analytics.analytics_consent = true
	_expect(analytics.log_boss_defeated(15), "boss event accepted after consent")
	_expect(analytics.log_ad_watched("get x2 Gold for offline time"), "rewarded event accepted")
	var events: Array[Dictionary] = analytics.get_debug_events()
	_expect(events.size() == 2, "exactly two opted-in events captured")
	_expect(events[0]["name"] == "boss_defeated", "boss event name")
	_expect(events[0]["parameters"]["stage"] == 15, "boss stage parameter")
	_expect(events[1]["name"] == "ad_watched", "rewarded event name")
	_expect(events[1]["parameters"]["placement"] == "offline_gold_x2", "stable rewarded placement")
	_expect(ANALYTICS_SCRIPT.normalize_ad_placement("restore 100% HP") == "full_heal", "heal placement normalization")
	_expect(ANALYTICS_SCRIPT.normalize_ad_placement("revive hero") == "revive", "revive placement normalization")
	analytics.free()


func _test_notification_contract() -> void:
	var reminders: Array[Dictionary] = ENGAGEMENT_SCRIPT.get_reminder_definitions()
	_expect(reminders.size() == 2, "two return reminders")
	_expect(reminders[0]["id"] != reminders[1]["id"], "notification IDs are unique")
	_expect(reminders[0]["delay_seconds"] == 12 * 60 * 60, "D1 reminder after 12 hours")
	_expect(reminders[1]["delay_seconds"] == 24 * 60 * 60, "D1 reminder after 24 hours")
	_expect(ENGAGEMENT_SCRIPT.OFFLINE_REWARD_DEEPLINK.ends_with("offline-gold"), "offline reward deep link")
	_expect(not "interval" in reminders[0], "reminders are one-shot")
	_expect(ENGAGEMENT_SCRIPT.is_channel_creation_success(OK), "new notification channel is accepted")
	_expect(ENGAGEMENT_SCRIPT.is_channel_creation_success(ERR_ALREADY_EXISTS), "existing notification channel is accepted after update")


func _test_android_release_configuration() -> void:
	_expect(ProjectSettings.get_setting("application/config/features").has("4.7"), "project targets Godot 4.7")
	_expect(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Vulkan crash path disabled")
	_expect(ProjectSettings.get_setting("display/window/handheld/orientation") == 6, "full sensor orientation")
	_expect_file_contains("res://export_presets.cfg", "version/code=53", "release version code bumped")
	_expect_file_contains("res://export_presets.cfg", "firebase/enable_analytics=true", "Firebase Analytics enabled in export")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "minifyEnabled true", "R8 enabled by release guard")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "shrinkResources true", "resource shrinking enabled")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "com.poingstudios.godot.admob.**", "release guard keeps the native AdMob bridge")
	_expect_file_contains("res://android/build/proguard-rules.pro", "com.poingstudios.godot.admob.**", "active R8 rules keep the native AdMob bridge")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "Consent form dismissed — continuing SDK startup", "successful UMP dismissal starts AdMob")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "_preload_rewarded_ad()", "rewarded ad is preloaded")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "_preload_interstitial_ad()", "interstitial ad is preloaded")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "3940256099942544/6300978111", "debug banner uses Google's test unit")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "3940256099942544/5224354917", "debug rewarded uses Google's test unit")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "3940256099942544/1033173712", "debug interstitial uses Google's test unit")
	_expect_file_contains("res://src/scripts/PlatformManager.gd", "Banner IMPRESSION recorded", "banner exposes a native impression diagnostic")
	_expect_file_contains("res://android/build/src/main/java/com/godot/game/GodotApp.java", "EdgeToEdge.enable(this)", "Android activity enables edge-to-edge")
	_expect_file_contains("res://android/build/build.gradle", "androidx.activity:activity:$versions.activityVersion", "modern AndroidX Activity is pinned")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "activityVersion    : '1.10.1'", "release guard restores the compatible Activity version")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "androidx.activity:activity:$versions.activityVersion", "release guard restores the Activity dependency")
	_expect_file_contains("res://addons/android_release_guard/plugin.gd", "SCHEDULE_EXACT_ALARM", "exact alarm removal rule present")
	_expect_file_contains("res://export_presets.cfg", "exclude_filter=\"tests/*", "tests excluded from Android release")
	_expect(FileAccess.file_exists("res://addons/GodotGooglePlayBilling/bin/release/GodotGooglePlayBilling-release.aar"), "Billing release AAR installed")
	_expect(FileAccess.file_exists("res://addons/NotificationSchedulerPlugin/bin/release/NotificationSchedulerPlugin-release.aar"), "notification release AAR installed")
	_expect(FileAccess.file_exists("res://android/firebase_analytics/firebase_analytics.release.aar"), "Firebase Analytics release AAR installed")
	_expect(not FileAccess.file_exists("res://src/scripts/TutorialManager.gd"), "tutorial manager removed")
	_expect_file_not_contains("res://src/scenes/GameBattleManager.gd", "tutorial", "gameplay contains no tutorial flow")
	_expect_file_contains("res://src/scenes/GameBattleManager.gd", "offline_reward_requested.connect", "warm notification routes to gameplay reward")
	_expect_file_contains("res://src/scenes/node_2d.tscn", "name=\"RemoveAdsButton\"", "victory screen contains Remove Ads offer")
	_expect_file_contains("res://src/scenes/GameBattleManager.gd", "_on_remove_ads_button_pressed", "victory offer opens the Play product screen")


func _expect_file_contains(path: String, needle: String, description: String) -> void:
	_expect(FileAccess.file_exists(path) and needle in FileAccess.get_file_as_string(path), description)


func _expect_file_not_contains(path: String, needle: String, description: String) -> void:
	_expect(FileAccess.file_exists(path) and not needle in FileAccess.get_file_as_string(path).to_lower(), description)


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("Check failed: %s" % description)
