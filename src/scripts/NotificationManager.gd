extends Node

var info_label: Label
var canvas_layer: CanvasLayer

var _current_stage: int = 1
var _boss_roster: Dictionary = {}

var _notification_queue: Array[Dictionary] = []
var _notification_showing: bool = false
var _toast_node: Label = null
var _toast_tween: Tween = null


func setup(refs: Dictionary):
	info_label = refs.get("info_label")
	canvas_layer = refs.get("canvas_layer")


func update_stage_info(stage: int, boss_roster: Dictionary):
	_current_stage = stage
	_boss_roster = boss_roster
	_refresh_info_label()


func _refresh_info_label():
	# Persistent stage description (e.g. "Jungle 1/15 Brad the Influencer") is
	# disabled by request — the StageBar already shows progression visually.
	# InfoLabel is still used for transient notifications (level up, etc.).
	if not info_label:
		return
	info_label.text = ""


func queue_notification(message: String, color: Color = Color.WHITE, duration: float = 1.5):
	_notification_queue.append({"text": message, "color": color, "duration": duration})
	if not _notification_showing:
		_process_notification_queue()


func _process_notification_queue():
	if _notification_queue.is_empty():
		_notification_showing = false
		_refresh_info_label()
		return
	_notification_showing = true
	var notif = _notification_queue.pop_front()
	if info_label:
		info_label.text = notif.text
		info_label.modulate = notif.color
		info_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(info_label, "modulate:a", 1.0, 0.15)
		tween.tween_interval(notif.duration)
		tween.tween_property(info_label, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			info_label.modulate = Color.WHITE
			_process_notification_queue()
		)


func show_toast(text: String, duration: float = 2.0):
	if _toast_tween:
		_toast_tween.kill()
	if _toast_node and is_instance_valid(_toast_node):
		_toast_node.queue_free()

	var toast := Label.new()
	toast.text = text
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.custom_minimum_size = Vector2(300, 36)
	toast.add_theme_font_size_override("font_size", 14)
	toast.add_theme_color_override("font_color", Color.WHITE)
	var ls := LabelSettings.new()
	ls.outline_size = 3
	ls.outline_color = Color(0, 0, 0, 0.9)
	toast.label_settings = ls
	toast.z_index = 200
	toast.modulate = Color(1, 1, 1, 0)

	var view := get_viewport().get_visible_rect().size
	var target_y := 60.0
	toast.position = Vector2((view.x - toast.custom_minimum_size.x) * 0.5, target_y)
	canvas_layer.add_child(toast)

	_toast_node = toast
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast, "modulate:a", 1.0, 0.14)
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.2)
	_toast_tween.tween_callback(func():
		if is_instance_valid(toast):
			toast.queue_free()
		if _toast_node == toast:
			_toast_node = null
	)
