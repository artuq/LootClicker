extends Control

@onready var volume_slider = %VolumeSlider

func _ready():
	# Initialize slider with current value
	if get_node_or_null("/root/SettingsManager"):
		volume_slider.value = get_node("/root/SettingsManager").master_volume

func _on_volume_slider_value_changed(value: float):
	if get_node_or_null("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		sm.master_volume = value
		sm.apply_settings()

func _on_back_button_pressed():
	if get_node_or_null("/root/SettingsManager"):
		get_node("/root/SettingsManager").save_settings()
	
	# If we are an overlay (during pause), just remove ourselves
	if get_parent() is CanvasLayer:
		queue_free()
		get_tree().paused = false
	else:
		# If we are a separate scene from the main menu
		get_tree().change_scene_to_file("res://TitleScreen.tscn")
