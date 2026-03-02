extends Control

@onready var volume_slider = %VolumeSlider
const PRIVACY_POLICY_URL := "https://gist.github.com/artuq/24733cc4575012af3ec41bf53d2088cb"

func _ready():
	# Initialize slider with current value
	if get_node_or_null("/root/SettingsManager"):
		volume_slider.value = get_node("/root/SettingsManager").master_volume
	
	# Hide save/load container (no longer used — auto-checkpoint system)
	var save_load_container = get_node_or_null("%SaveLoadContainer")
	if save_load_container:
		save_load_container.visible = false

func setup():
	pass  # Volume-only settings, no save/load needed

func _spawn_feedback(msg: String):
	var lbl = Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	lbl.anchors_preset = Control.PRESET_CENTER_BOTTOM
	lbl.position.y -= 30
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 1.2)
	tw.tween_callback(lbl.queue_free)

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
		get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")

func _on_privacy_button_pressed():
	var ok = OS.shell_open(PRIVACY_POLICY_URL)
	if ok != OK:
		_spawn_feedback("FAILED TO OPEN PRIVACY POLICY")
	else:
		_spawn_feedback("OPENING PRIVACY POLICY...")
