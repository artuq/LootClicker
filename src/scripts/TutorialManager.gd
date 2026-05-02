extends Node

signal tutorial_completed
signal request_timer_stop
signal request_timer_start

var tutorial_shown: bool = false
var tutorial_active: bool = false
var tutorial_step: int = 0
var tutorial_tap_count: int = 0
var tutorial_click_cooldown: bool = false
var tutorial_layer: CanvasLayer = null
var tutorial_dimmer: ColorRect = null
var tutorial_bubble: Label = null
var tutorial_hand: TextureRect = null
var tutorial_enemy_pulse: Tween = null
var tutorial_enemy_base_scale: Vector2 = Vector2.ONE

const TUTORIAL_NONE := 0
const TUTORIAL_COMBAT_TAPS := 1
const TUTORIAL_AUTO_ATTACK := 2
const TUTORIAL_LEVEL_UP := 3
const TUTORIAL_STAGE_PROGRESS := 4
const TUTORIAL_DONE := 5

var _hand_texture: Texture2D
var _enemy_sprite: Sprite2D
var _xp_bar: Control
var _stage_label: Control
var _player: Node
var _enemy_hud: Node
var _owner_node: Node  # GBM reference for add_child/create_tween

func setup(refs: Dictionary):
	_owner_node = refs.get("owner")
	_enemy_sprite = refs.get("enemy_sprite")
	_xp_bar = refs.get("xp_bar")
	_stage_label = refs.get("stage_label")
	_player = refs.get("player")
	_enemy_hud = refs.get("enemy_hud")
	_hand_texture = refs.get("hand_texture")

func show_tutorial():
	if tutorial_shown:
		return
	tutorial_shown = true
	tutorial_active = true
	tutorial_step = TUTORIAL_COMBAT_TAPS
	tutorial_tap_count = 0
	_create_overlay()
	_enter_combat_taps_step()

func clear_overlay():
	if tutorial_enemy_pulse:
		tutorial_enemy_pulse.kill()
	tutorial_enemy_pulse = null
	if tutorial_layer and is_instance_valid(tutorial_layer):
		tutorial_layer.queue_free()
	tutorial_layer = null
	tutorial_dimmer = null
	tutorial_bubble = null
	tutorial_hand = null

func _create_overlay():
	if tutorial_layer and is_instance_valid(tutorial_layer):
		tutorial_layer.queue_free()

	tutorial_layer = CanvasLayer.new()
	tutorial_layer.layer = 120
	_owner_node.add_child(tutorial_layer)

	tutorial_dimmer = ColorRect.new()
	tutorial_dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_dimmer.color = Color(0, 0, 0, 0.45)
	tutorial_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_layer.add_child(tutorial_dimmer)

	tutorial_bubble = Label.new()
	tutorial_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_bubble.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_bubble.custom_minimum_size = Vector2(280, 0)
	tutorial_bubble.add_theme_font_size_override("font_size", 18)
	tutorial_bubble.add_theme_color_override("font_color", Color.WHITE)
	var ls = LabelSettings.new()
	ls.outline_size = 3
	ls.outline_color = Color.BLACK
	tutorial_bubble.label_settings = ls
	tutorial_layer.add_child(tutorial_bubble)

	tutorial_hand = TextureRect.new()
	tutorial_hand.texture = _hand_texture
	tutorial_hand.custom_minimum_size = Vector2(58, 58)
	tutorial_hand.size = Vector2(58, 58)
	tutorial_hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tutorial_hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tutorial_layer.add_child(tutorial_hand)

func _clamp_to_viewport(pos: Vector2, node_size: Vector2) -> Vector2:
	var view: Vector2 = _owner_node.get_viewport().get_visible_rect().size
	var margin := 12.0
	var clamped_x = clampf(pos.x, margin, max(margin, view.x - node_size.x - margin))
	var clamped_y = clampf(pos.y, margin, max(margin, view.y - node_size.y - margin))
	return Vector2(clamped_x, clamped_y)

func _set_hint(text: String, hand_pos: Vector2, bubble_pos: Vector2):
	if not tutorial_active:
		return
	if not tutorial_layer or not is_instance_valid(tutorial_layer) or not tutorial_bubble or not tutorial_hand:
		_create_overlay()
	if not tutorial_bubble or not tutorial_hand:
		return
	tutorial_bubble.text = text
	tutorial_bubble.reset_size()
	tutorial_bubble.position = _clamp_to_viewport(bubble_pos, tutorial_bubble.size if tutorial_bubble.size.y > 0 else Vector2(280, 80))
	tutorial_hand.position = _clamp_to_viewport(hand_pos, tutorial_hand.custom_minimum_size)
	tutorial_hand.scale = Vector2.ONE
	var bounce_start_y := tutorial_hand.position.y
	if tutorial_enemy_pulse:
		tutorial_enemy_pulse.kill()
	tutorial_enemy_pulse = _owner_node.create_tween().set_loops()
	tutorial_enemy_pulse.tween_property(tutorial_hand, "position:y", bounce_start_y + 7.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tutorial_enemy_pulse.parallel().tween_property(tutorial_hand, "scale", Vector2(0.92, 0.92), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tutorial_enemy_pulse.tween_property(tutorial_hand, "position:y", bounce_start_y, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tutorial_enemy_pulse.parallel().tween_property(tutorial_hand, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _enter_combat_taps_step():
	if not tutorial_active:
		return
	tutorial_step = TUTORIAL_COMBAT_TAPS
	tutorial_tap_count = 0
	tutorial_click_cooldown = false

	request_timer_stop.emit()

	tutorial_enemy_base_scale = _enemy_sprite.scale
	_enemy_sprite.modulate = Color(1.2, 1.2, 1.2, 1.0)
	_enemy_sprite.scale = tutorial_enemy_base_scale * 1.05

	var enemy_pos = _enemy_sprite.global_position
	_set_hint(
		"TAP to attack! (3 times)",
		enemy_pos + Vector2(-52, 55),
		enemy_pos + Vector2(-130, -210)
	)

func enter_auto_attack_step(current_enemy: Node):
	if not tutorial_active:
		return
	tutorial_step = TUTORIAL_AUTO_ATTACK

	if tutorial_dimmer:
		tutorial_dimmer.color.a = 0.25
	_set_hint(
		"Great! You also attack automatically.",
		_enemy_sprite.global_position + Vector2(-90, 60),
		_enemy_sprite.global_position + Vector2(-160, -140)
	)

	if current_enemy:
		var low_hp = max(6, int(_player.get_total_damage() * 1.2))
		current_enemy.current_hp = min(current_enemy.current_hp, low_hp)
		_enemy_hud.on_hp_changed(current_enemy.current_hp, current_enemy.max_hp)

	request_timer_start.emit()

func show_xp_hint_step() -> void:
	if not tutorial_active:
		return
	if tutorial_dimmer:
		tutorial_dimmer.color.a = 0.4
	var xp_pos = _xp_bar.global_position if _xp_bar else Vector2(110, 96)
	_set_hint(
		"Collect XP to level up!",
		xp_pos + Vector2(70, -28),
		xp_pos + Vector2(-65, -68)
	)
	await _owner_node.get_tree().create_timer(1.0).timeout

func show_stage_progress_step() -> void:
	if not tutorial_active or tutorial_step != TUTORIAL_STAGE_PROGRESS:
		return
	if tutorial_dimmer:
		tutorial_dimmer.color.a = 0.28
	var stage_pos = _stage_label.global_position if _stage_label else Vector2(140, 24)
	_set_hint(
		"Every 10 stages is a Boss fight. Good luck!",
		stage_pos + Vector2(122, 34),
		stage_pos + Vector2(-30, -40)
	)
	await _owner_node.get_tree().create_timer(1.7).timeout
	finish()

func finish():
	tutorial_active = false
	tutorial_step = TUTORIAL_DONE
	_enemy_sprite.modulate = Color.WHITE
	_enemy_sprite.scale = tutorial_enemy_base_scale
	if tutorial_layer and is_instance_valid(tutorial_layer):
		var fade = _owner_node.create_tween()
		fade.tween_property(tutorial_layer, "modulate:a", 0.0, 0.22)
		fade.tween_callback(Callable(self, "clear_overlay"))
	else:
		clear_overlay()
	tutorial_completed.emit()
