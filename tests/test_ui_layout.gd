extends SceneTree

const SETTINGS_SCENE := preload("res://src/scenes/SettingsScene.tscn")
const STORE_SCENE := preload("res://src/scenes/StoreScene.tscn")
const TITLE_SCENE := preload("res://src/scenes/TitleScreen.tscn")

var _checks: int = 0
var _failures: int = 0
const EXPECTED_CHECKS := 12


func _initialize() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	for window_size: Vector2i in [
		Vector2i(360, 640),
		Vector2i(800, 1280),
		Vector2i(1280, 800),
		Vector2i(1600, 900),
	]:
		root.size = window_size
		await process_frame
		await _check_centered_scene(SETTINGS_SCENE, "Panel", "Settings", window_size)
		await _check_centered_scene(STORE_SCENE, "Panel", "Store", window_size)

	root.size = Vector2i(1280, 800)
	var title = TITLE_SCENE.instantiate()
	root.add_child(title)
	await process_frame
	_expect(_inside_visible_rect(title.get_node("MenuButtons") as Control), "Title menu fits landscape large screen")
	_expect((title.get_node("Background") as Control).get_global_rect().size.x > 0, "Title background is laid out")
	title.free()
	await process_frame

	var store = STORE_SCENE.instantiate()
	root.add_child(store)
	await process_frame
	_expect(store.get_node("Panel/Margin/VBox/BuyButton").text.begins_with("BUY") or store.get_node("Panel/Margin/VBox/BuyButton").disabled, "Store exposes a safe purchase state")
	var description: String = str(store.get_node("Panel/Margin/VBox/ProductDescription").text).to_lower()
	_expect("every ad" in description and "without watching" in description, "Store explains the complete ad-free entitlement")
	store.free()
	await process_frame
	await _stop_test_audio()
	if _checks != EXPECTED_CHECKS:
		_failures += 1
		push_error("Test run was interrupted: expected %d checks, ran %d" % [EXPECTED_CHECKS, _checks])

	if _failures == 0:
		print("PASS: %d UI layout checks" % _checks)
		quit(0)
	else:
		push_error("FAIL: %d of %d UI layout checks" % [_failures, _checks])
		quit(1)


func _check_centered_scene(scene: PackedScene, panel_path: String, label: String, window_size: Vector2i) -> void:
	var instance = scene.instantiate()
	root.add_child(instance)
	await process_frame
	var panel := instance.get_node(panel_path) as Control
	_expect(_inside_visible_rect(panel), "%s panel fits %dx%d" % [label, window_size.x, window_size.y])
	instance.free()
	await process_frame


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
	# Let deferred frees and the threaded audio decoder release their references.
	for _frame in range(10):
		await process_frame


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("Check failed: %s" % description)
