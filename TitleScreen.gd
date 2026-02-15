extends Control

@onready var continue_btn = %ContinueButton

func _ready():
	# Uruchamiamy muzykę przez AudioManager (Autoload)
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()
	
	# Ustawiamy tło tak, aby nie blokowało kliknięć (dodatkowe zabezpieczenie w kodzie)
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Sprawdzamy czy istnieje plik zapisu dla slotu 1
	var save_path = "user://savegame_slot1.json"
	if not FileAccess.file_exists(save_path):
		if continue_btn:
			continue_btn.disabled = true
			continue_btn.modulate.a = 0.5

func _on_continue_button_pressed():
	print("DEBUG: CLICKED CONTINUE")
	_start_game("continue")

func _on_new_game_button_pressed():
	print("DEBUG: CLICKED NEW GAME")
	_start_game("new_game")

func _start_game(mode: String):
	# Używamy bezpiecznego ładowania klasy
	var manager = load("res://GameBattleManager.gd")
	if manager:
		manager.startup_mode = mode
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
