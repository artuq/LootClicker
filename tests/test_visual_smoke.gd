extends SceneTree

## Visible smoke suite. Run without --headless: it opens a real Godot window,
## walks through production UI/gameplay, shows each check, then closes itself.

const TITLE_SCENE := preload("res://src/scenes/TitleScreen.tscn")
const SETTINGS_SCENE := preload("res://src/scenes/SettingsScene.tscn")
const STORE_SCENE := preload("res://src/scenes/StoreScene.tscn")
const GAME_SCENE_PATH := "res://src/scenes/node_2d.tscn"
const EXPECTED_CHECKS := 26

var _checks: int = 0
var _failures: int = 0
var _status_label: Label


func _initialize() -> void:
	call_deferred("_run_suite")


func _run_suite() -> void:
	DisplayServer.window_set_title("Joana Indiana — visible production smoke tests")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	await _show_ui_scene(TITLE_SCENE, "TITLE SCREEN • 420 × 760", Vector2i(420, 760), "MenuButtons")
	await _show_ui_scene(SETTINGS_SCENE, "SETTINGS • privacy / notifications / store", Vector2i(420, 760), "Panel")
	await _show_ui_scene(STORE_SCENE, "GOOGLE PLAY STORE • Remove Ads", Vector2i(420, 760), "Panel")
	await _show_gameplay()
	await _stop_test_audio()
	if _checks != EXPECTED_CHECKS:
		_failures += 1
		push_error("Visible suite was interrupted: expected %d checks, ran %d" % [EXPECTED_CHECKS, _checks])

	var result_layer := _make_status_layer(
		"PASS • %d visible checks\nWindow will close automatically…" % _checks
		if _failures == 0
		else "FAIL • %d errors in %d checks\nSee the Godot log." % [_failures, _checks],
		Color(0.13, 0.55, 0.24, 0.96) if _failures == 0 else Color(0.72, 0.12, 0.12, 0.96)
	)
	root.add_child(result_layer)
	await create_timer(1.6).timeout
	result_layer.free()
	print("PASS: %d visible production smoke checks" % _checks if _failures == 0 else "FAIL: %d/%d visible production smoke checks" % [_failures, _checks])
	quit(0 if _failures == 0 else 1)


func _show_ui_scene(scene: PackedScene, step: String, size: Vector2i, control_path: String) -> void:
	_set_window_size(size)
	var instance := scene.instantiate()
	root.add_child(instance)
	var status := _make_status_layer("TEST • " + step, Color(0.10, 0.26, 0.58, 0.94))
	root.add_child(status)
	await process_frame
	await process_frame
	var control := instance.get_node_or_null(control_path) as Control
	_expect(control != null, "%s has %s" % [step, control_path])
	if control:
		_expect(_inside_visible_rect(control), "%s fits the visible window" % step)
	await create_timer(0.85).timeout
	status.free()
	instance.free()
	await process_frame


func _show_gameplay() -> void:
	_set_window_size(Vector2i(420, 760))
	set_meta("startup_mode", "new_game")
	# Runtime loading happens after project autoloads register their global names.
	var game_scene := load(GAME_SCENE_PATH) as PackedScene
	_expect(game_scene != null, "gameplay scene loads with all autoloads")
	if game_scene == null:
		return
	var game := game_scene.instantiate()
	root.add_child(game)
	var status := _make_status_layer("TEST • REAL GAMEPLAY • no tutorial • auto-attack", Color(0.38, 0.16, 0.58, 0.94))
	root.add_child(status)
	await process_frame
	await process_frame
	await create_timer(0.45).timeout

	var manager := game.get_node_or_null("GameManager")
	_expect(manager != null, "gameplay manager starts")
	_expect(manager != null and manager.get_script() != null, "gameplay script compiles")
	if manager == null or manager.get_script() == null:
		status.free()
		game.free()
		await process_frame
		return
	if manager and manager.get_script() != null:
		_expect(manager.get_node_or_null("TutorialManager") == null, "tutorial layer and manager are absent")
		_expect(manager.get("current_enemy") != null, "first enemy spawns immediately")
		_expect(bool(manager.get("in_combat")), "combat begins immediately")
		var player_timer := manager.get("player_timer") as Timer
		var enemy_timer := manager.get("enemy_timer") as Timer
		_expect(player_timer != null and not player_timer.is_stopped(), "auto-attack runs immediately")
		_expect(enemy_timer != null and not enemy_timer.is_stopped(), "enemy attack timer runs")
		for _tap in range(3):
			manager.call("_on_click_area_pressed")
			await create_timer(0.14).timeout

	await create_timer(0.45).timeout
	status.get_node("Panel/Status").text = "TEST • VICTORY OFFER • Remove Ads below Main Menu"
	manager.call("_show_victory_popup")
	await create_timer(1.15).timeout
	var main_menu_button := game.get_node_or_null("VictoryLayer/VictoryUI/VBox/MainMenuButton") as Button
	var remove_ads_button := game.get_node_or_null("VictoryLayer/VictoryUI/VBox/RemoveAdsButton") as Button
	var victory_panel := game.get_node_or_null("VictoryLayer/VictoryUI") as Control
	var portrait_bottom_panel := game.get_node_or_null("BottomNavLayer/BottomPanel") as Control
	_expect(victory_panel != null and _inside_visible_rect(victory_panel), "expanded victory panel fits portrait")
	_expect(
		victory_panel != null
		and portrait_bottom_panel != null
		and victory_panel.get_global_rect().end.y <= portrait_bottom_panel.get_global_rect().position.y + 1.0,
		"victory offer stays above bottom navigation"
	)
	_expect(remove_ads_button != null and remove_ads_button.visible, "Remove Ads offer is visible in editor/Android")
	_expect(
		main_menu_button != null
		and remove_ads_button != null
		and remove_ads_button.get_index() > main_menu_button.get_index(),
		"Remove Ads offer is below Main Menu"
	)
	manager.call("_on_remove_ads_button_pressed")
	await process_frame
	await process_frame
	var store_overlay := manager.get("_store_overlay") as CanvasLayer
	_expect(store_overlay != null and store_overlay.get_child_count() == 1, "Remove Ads opens the product and restore screen")
	await create_timer(0.75).timeout
	if store_overlay:
		store_overlay.free()
	await process_frame

	status.get_node("Panel/Status").text = "TEST • REMOVE ALL ADS • bonuses without video"
	var purchases := root.get_node_or_null("PurchaseManager")
	var platform := root.get_node_or_null("PlatformManager")
	var original_android: bool = bool(platform.get("is_android"))
	var original_owned: bool = bool(purchases.remove_ads_owned) if purchases else false
	platform.set("is_android", true)
	if purchases:
		purchases.remove_ads_owned = true
	manager.call("_update_remove_ads_offer")
	_expect(not bool(platform.call("are_ads_enabled")), "Remove Ads owner has every ad format disabled")
	_expect(not bool(platform.call("is_ad_available")) and bool(platform.call("is_reward_available")), "ad-free bonuses remain available without an ad")
	var reward_result := {"granted": false, "failed": false}
	platform.call(
		"request_rewarded_ad",
		"restore 100% HP",
		func(): reward_result["granted"] = true,
		func(): reward_result["failed"] = true,
		manager
	)
	_expect(bool(reward_result["granted"]) and not bool(reward_result["failed"]), "reward request grants immediately for an owner")
	var player = manager.get("player")
	player.current_hp = max(1, player.max_hp - 1)
	manager.set("ad_uses_this_stage", 0)
	manager.call("_update_watch_ad_button")
	var heal_button := game.get_node_or_null("VictoryLayer/VictoryUI/VBox/WatchAdButton") as Button
	_expect(heal_button != null and not heal_button.disabled and heal_button.text == "FULL HEAL", "Full Heal is free and contains no ad label")
	_expect(remove_ads_button != null and not remove_ads_button.visible, "owned Remove Ads offer disappears")
	await create_timer(0.85).timeout
	if purchases:
		purchases.remove_ads_owned = original_owned
	platform.set("is_android", original_android)

	status.get_node("Panel/Status").text = "TEST • LIVE RESIZE • landscape / large screen"
	_set_window_size(Vector2i(900, 540))
	await process_frame
	await process_frame
	var top_hud := game.get_node_or_null("CanvasLayer/TopHUD") as Control
	var bottom_panel := game.get_node_or_null("BottomNavLayer/BottomPanel") as Control
	_expect(top_hud != null and _inside_visible_rect(top_hud), "gameplay top HUD fits landscape")
	_expect(bottom_panel != null and _inside_visible_rect(bottom_panel), "gameplay bottom panel fits landscape")
	await create_timer(1.0).timeout

	status.free()
	game.free()
	await process_frame
	await process_frame


func _set_window_size(size: Vector2i) -> void:
	DisplayServer.window_set_size(size)
	root.size = size
	var screen_size := DisplayServer.screen_get_size()
	DisplayServer.window_set_position((screen_size - size) / 2)


func _make_status_layer(message: String, color: Color) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 500
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 8
	panel.offset_top = 8
	panel.offset_right = -8
	panel.offset_bottom = 72
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	_status_label = Label.new()
	_status_label.name = "Status"
	_status_label.text = message
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_font_size_override("font_size", 16)
	_status_label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(_status_label)
	return layer


func _inside_visible_rect(control: Control) -> bool:
	var visible_size := root.get_visible_rect().size
	var rect := control.get_global_rect()
	return (
		rect.position.x >= -1.0
		and rect.position.y >= -1.0
		and rect.end.x <= visible_size.x + 1.0
		and rect.end.y <= visible_size.y + 1.0
	)


func _stop_test_audio() -> void:
	var audio := root.get_node_or_null("AudioManager")
	if audio:
		audio.stop_music()
		if audio.music_player:
			audio.music_player.stream = null
	await process_frame
	await process_frame


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("  OK  %s" % description)
		return
	_failures += 1
	push_error("Visible smoke check failed: %s" % description)
