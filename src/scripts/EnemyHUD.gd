extends Node

var enemy_hp_bar: ProgressBar
var enemy_nameplate_label: Label
var enemy_attack_bar: ProgressBar

var style_green: StyleBoxTexture
var style_yellow: StyleBoxTexture
var style_red: StyleBoxTexture


func setup(refs: Dictionary):
	enemy_hp_bar = refs.get("enemy_hp_bar")
	enemy_nameplate_label = refs.get("enemy_nameplate_label")
	enemy_attack_bar = refs.get("enemy_attack_bar")
	_init_styles(refs.get("bar_green"), refs.get("bar_yellow"), refs.get("bar_red"))
	_init_ui()


func _init_styles(bar_green: Texture2D, bar_yellow: Texture2D, bar_red: Texture2D):
	style_green = StyleBoxTexture.new()
	style_green.texture = bar_green
	style_green.texture_margin_left = 6
	style_green.texture_margin_right = 6
	style_green.texture_margin_top = 6
	style_green.texture_margin_bottom = 6

	style_yellow = StyleBoxTexture.new()
	style_yellow.texture = bar_yellow
	style_yellow.texture_margin_left = 6
	style_yellow.texture_margin_right = 6
	style_yellow.texture_margin_top = 6
	style_yellow.texture_margin_bottom = 6

	style_red = StyleBoxTexture.new()
	style_red.texture = bar_red
	style_red.texture_margin_left = 6
	style_red.texture_margin_right = 6
	style_red.texture_margin_top = 6
	style_red.texture_margin_bottom = 6


func _init_ui():
	if enemy_attack_bar:
		enemy_attack_bar.min_value = 0.0
		enemy_attack_bar.max_value = 1.0
		enemy_attack_bar.value = 0.0
		enemy_attack_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if enemy_nameplate_label:
		enemy_nameplate_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if enemy_hp_bar:
		enemy_hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_hp_bar.min_value = 0.0


func on_hp_changed(current_hp: int, max_hp: int):
	if not enemy_hp_bar:
		return
	enemy_hp_bar.min_value = 0
	enemy_hp_bar.max_value = max_hp
	_tween_bar(enemy_hp_bar, float(current_hp), 0.12)
	update_hp_bar_style(enemy_hp_bar)


func update_hp_bar_style(bar: ProgressBar):
	if not bar: return
	var percent = (float(bar.value) / bar.max_value) * 100.0 if bar.max_value > 0 else 0.0
	if percent > 50:
		bar.add_theme_stylebox_override("fill", style_green)
	elif percent > 25:
		bar.add_theme_stylebox_override("fill", style_yellow)
	else:
		bar.add_theme_stylebox_override("fill", style_red)


func _tween_bar(bar: Range, target: float, duration: float = 0.2):
	if not bar: return
	var t = bar.create_tween()
	t.tween_property(bar, "value", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func hide_legacy():
	var gbm = get_parent()
	var old_enemy_label = gbm.get_node_or_null("../CanvasLayer/TopHUD/VBox/EnemyHPLabel")
	if old_enemy_label:
		old_enemy_label.visible = false
		old_enemy_label.text = ""
	var old_enemy_bar = gbm.get_node_or_null("../CanvasLayer/TopHUD/VBox/EnemyHPBar")
	if old_enemy_bar:
		old_enemy_bar.visible = false


func show_boss_greeting(text: String):
	if enemy_nameplate_label: enemy_nameplate_label.visible = false

	var greeting_layer = CanvasLayer.new()
	greeting_layer.layer = 90
	greeting_layer.add_to_group("boss_greeting")
	add_child(greeting_layer)

	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate = Color(1, 1, 1, 0)
	greeting_layer.add_child(overlay)

	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.GOLD)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.position = Vector2(-150, -20)
	lbl.size = Vector2(300, 40)
	lbl.modulate = Color(1, 1, 1, 0)
	greeting_layer.add_child(lbl)

	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(lbl, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		if enemy_nameplate_label: enemy_nameplate_label.visible = true
		greeting_layer.queue_free()
	)

func dismiss_greeting():
	for node in get_tree().get_nodes_in_group("boss_greeting"):
		if is_instance_valid(node):
			node.queue_free()
	if enemy_nameplate_label: enemy_nameplate_label.visible = true
