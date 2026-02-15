extends Control

func _on_play_button_pressed():
	print("PLAY BUTTON PRESSED - LOADING ARENA")
	get_tree().change_scene_to_file("res://node_2d.tscn")
