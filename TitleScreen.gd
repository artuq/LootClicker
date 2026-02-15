extends Control

@onready var continue_btn = %ContinueButton

func _ready():
	# Sprawdzamy czy istnieje plik zapisu dla slotu 1
	var save_path = "user://savegame_slot1.json"
	if not FileAccess.file_exists(save_path):
		continue_btn.disabled = true
		continue_btn.modulate.a = 0.5 # Lekko przezroczysty żeby pokazać że nieaktywny

func _on_continue_button_pressed():
	print("START MODE: CONTINUE")
	GameBattleManager.startup_mode = "continue"
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_new_game_button_pressed():
	print("START MODE: NEW GAME")
	GameBattleManager.startup_mode = "new_game"
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
