extends Control

@onready var continue_btn = %ContinueButton
static var last_run_result: String = ""

func _ready():
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

	# Check if save file exists for slot 1 to enable/disable continue
	var save_path = "user://savegame_slot1.json"
	if not FileAccess.file_exists(save_path):
		if continue_btn:
			continue_btn.disabled = true
			continue_btn.modulate.a = 0.5

	# Add juice to all menu buttons
	for btn in $MenuButtons.get_children():
		if btn is Button:
			_add_button_juice(btn)

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
	get_tree().change_scene_to_file("res://SettingsScene.tscn")

func _start_game(mode: String):
	# Set static mode on the manager class
	GameBattleManager.startup_mode = mode
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
