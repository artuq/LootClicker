extends Control

@onready var continue_btn = %ContinueButton
@onready var new_game_btn = %NewGameButton
static var last_run_result: String = ""
var game_starting: bool = false
var _transition_overlay: ColorRect = null

func _ready():
	# Force portrait orientation on Android
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

	# Start music via AudioManager (Autoload)
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()

	if last_run_result == "DEFEAT":
		if $MenuButtons.has_node("Title"):
			$MenuButtons/Title.text = "GAME OVER"
			$MenuButtons/Title.modulate = Color.RED
		last_run_result = "" # Reset

	# Set background mouse filter to ignore to avoid blocking clicks
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MenuButtons.mouse_filter = Control.MOUSE_FILTER_PASS

	# Check if save file exists for slot 1 to enable/disable continue
	var save_path = "user://savegame_slot1.json"
	if not FileAccess.file_exists(save_path):
		if continue_btn:
			continue_btn.visible = false

	# Add juice to all menu buttons
	for btn in $MenuButtons.get_children():
		if btn is Button:
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			_add_button_juice(btn)

	# New Game must always be tappable.
	if new_game_btn:
		new_game_btn.disabled = false
		new_game_btn.modulate.a = 1.0

	# Scene entry fade to avoid hard cut from splash.
	UIAnimations.fade_in(self, 0.28)
	_build_transition_overlay()

func _build_transition_overlay():
	if _transition_overlay and is_instance_valid(_transition_overlay):
		return
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Keep overlay non-blocking while invisible.
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.modulate.a = 0.0
	_transition_overlay.z_index = 300
	add_child(_transition_overlay)

func _add_button_juice(btn: Button):
	btn.pivot_offset = btn.size / 2
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.05)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

func _on_continue_button_pressed():
	print("DEBUG: CLICKED CONTINUE")
	_start_game("continue")

func _on_new_game_button_pressed():
	print("DEBUG: CLICKED NEW GAME")
	_start_game("new_game")

func _on_settings_button_pressed():
	var overlay = CanvasLayer.new()
	overlay.layer = 100
	add_child(overlay)
	var settings = load("res://src/scenes/SettingsScene.tscn").instantiate()
	overlay.add_child(settings)
	# No save/load on title screen — just volume

func _start_game(mode: String):
	if game_starting:
		return
	game_starting = true
	for btn in $MenuButtons.get_children():
		if btn is Button:
			btn.disabled = true

	# Pass startup mode safely to the next scene.
	get_tree().set_meta("startup_mode", mode)
	call_deferred("_go_to_game_scene_with_transition")

func _go_to_game_scene_with_transition():
	if not _transition_overlay or not is_instance_valid(_transition_overlay):
		_go_to_game_scene()
		return
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_transition_overlay, "modulate:a", 1.0, 0.18)
	await t.finished
	_go_to_game_scene()

func _go_to_game_scene():
	var err := get_tree().change_scene_to_file("res://src/scenes/node_2d.tscn")
	if err != OK:
		push_error("Failed to open gameplay scene, error code: %s" % err)
		game_starting = false
		if _transition_overlay and is_instance_valid(_transition_overlay):
			_transition_overlay.modulate.a = 0.0
			_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for btn in $MenuButtons.get_children():
			if btn is Button:
				btn.disabled = false

func _on_exit_button_pressed():
	get_tree().quit()
