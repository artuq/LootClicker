extends Control

@onready var volume_slider = %VolumeSlider
@onready var save_load_container = %SaveLoadContainer

var _save_callable: Callable
var _load_callable: Callable

func _ready():
	# Initialize slider with current value
	if get_node_or_null("/root/SettingsManager"):
		volume_slider.value = get_node("/root/SettingsManager").master_volume
	
	# Hide save/load by default (TitleScreen mode)
	if save_load_container:
		save_load_container.visible = false

func setup(save_fn: Callable = Callable(), load_fn: Callable = Callable()):
	# Call after adding to tree; shows save/load if callables provided
	_save_callable = save_fn
	_load_callable = load_fn
	
	if save_fn.is_valid() and load_fn.is_valid():
		if save_load_container:
			save_load_container.visible = true
		# Connect save buttons
		for i in range(1, 4):
			var save_btn = get_node_or_null("%%%s" % ("Save%d" % i))
			if save_btn and not save_btn.pressed.is_connected(_on_save_pressed):
				save_btn.pressed.connect(_on_save_pressed.bind(i))
			var load_btn = get_node_or_null("%%%s" % ("Load%d" % i))
			if load_btn and not load_btn.pressed.is_connected(_on_load_pressed):
				load_btn.pressed.connect(_on_load_pressed.bind(i))

func _on_save_pressed(slot: int):
	if _save_callable.is_valid():
		_save_callable.call(slot)
		_spawn_feedback("Saved to Slot %d!" % slot)

func _on_load_pressed(slot: int):
	if _load_callable.is_valid():
		_load_callable.call(slot)
		_spawn_feedback("Loaded Slot %d!" % slot)
		# Close settings after loading
		_on_back_button_pressed()

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
