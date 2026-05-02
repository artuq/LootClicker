extends Node

# References (set via setup())
var enemy_sprite: Node2D
var damage_label_scene: PackedScene
var damage_container: Node
var hp_label: Label
var hit_particles_scene: PackedScene
var canvas_layer: CanvasLayer

# Shake
var shake_intensity: float = 0.0
var original_enemy_pos: Vector2

# Idle animation
var idle_tween: Tween

# Vignette
var vignette_overlay: ColorRect
var vignette_tween: Tween
var is_near_death: bool = false
const NEAR_DEATH_THRESHOLD = 0.2

# Floating text burst control
var floating_text_burst_count: int = 0
var floating_text_last_spawn_ms: int = 0


func setup(refs: Dictionary):
	enemy_sprite = refs.get("enemy_sprite")
	damage_label_scene = refs.get("damage_label_scene")
	damage_container = refs.get("damage_container")
	hp_label = refs.get("hp_label")
	hit_particles_scene = refs.get("hit_particles_scene")
	canvas_layer = refs.get("canvas_layer")
	if enemy_sprite:
		original_enemy_pos = enemy_sprite.position
	_create_vignette_overlay()


func _process(delta):
	if not enemy_sprite:
		return
	if shake_intensity > 0:
		enemy_sprite.position = original_enemy_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0, delta * 50.0)
	else:
		enemy_sprite.position = original_enemy_pos


func play_hit_effect(is_crit: bool):
	shake_intensity = 18.0 if is_crit else 6.0

	# Particles
	if hit_particles_scene:
		var p = hit_particles_scene.instantiate()
		add_child(p)
		p.global_position = enemy_sprite.global_position
		if is_crit:
			p.amount = 32
			p.color = Color.ORANGE
			p.scale_amount_max = 7.0

	# Hit Flash
	var flash_duration: float = 0.15 if is_crit else 0.08
	var flash_tween = create_tween()
	enemy_sprite.modulate = Color(12, 12, 12) if is_crit else Color(8, 8, 8)
	flash_tween.tween_property(enemy_sprite, "modulate", Color.WHITE, flash_duration)

	# Hit Pause — freeze frame on crits
	if is_crit:
		get_tree().paused = true
		var pause_tween = get_tree().create_tween()
		pause_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		pause_tween.tween_interval(0.04)
		pause_tween.tween_callback(func(): get_tree().paused = false)

	# Squash & Stretch
	var base_scale = enemy_sprite.scale
	var hit_tween = create_tween()
	var squash_x: float = 0.7 if is_crit else 0.82
	var stretch_y: float = 1.25 if is_crit else 1.12
	enemy_sprite.scale = Vector2(base_scale.x * squash_x, base_scale.y * stretch_y)
	hit_tween.tween_property(enemy_sprite, "scale", base_scale, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func spawn_floating_text(text: String, color: Color, is_crit: bool = false):
	if !damage_label_scene:
		return
	var lbl = damage_label_scene.instantiate()
	lbl.text = text
	var ls = lbl.label_settings.duplicate()
	ls.font_color = color if not is_crit else Color.ORANGE
	ls.outline_size = 3
	ls.outline_color = Color.BLACK
	lbl.label_settings = ls
	lbl._is_crit = is_crit
	lbl.add_to_group("floating_text")
	lbl.add_to_group("floating_combat_text")

	var now_ms := Time.get_ticks_msec()
	if now_ms - floating_text_last_spawn_ms < 260:
		floating_text_burst_count = min(floating_text_burst_count + 1, 6)
	else:
		floating_text_burst_count = 0
	floating_text_last_spawn_ms = now_ms
	var stack_offset: float = float(floating_text_burst_count) * 24.0

	if damage_container:
		damage_container.add_child(lbl)
	else:
		add_child(lbl)

	var view_w = get_viewport().get_visible_rect().size.x
	var safe_left = view_w * 0.06
	var safe_right = view_w * 0.94 - 60.0

	if text.begins_with("LOOT"):
		lbl.global_position = enemy_sprite.global_position + Vector2(randf_range(-22, 22), -100 - stack_offset)
		lbl.scale = Vector2(1.5, 1.5)
	elif text.begins_with("ADRENALINE"):
		var center_top := Vector2(view_w * 0.5, 132)
		lbl.global_position = center_top + Vector2(randf_range(-42, 42), -stack_offset)
	elif color == Color.YELLOW:
		lbl.global_position = enemy_sprite.global_position + Vector2(randf_range(-28, 28), -50 - stack_offset)
	else:
		lbl.global_position = hp_label.global_position + Vector2(randf_range(18, 66), 40 - stack_offset)

	# Clamp X to safe screen bounds — prevent text clipping off-screen edges
	lbl.global_position.x = clampf(lbl.global_position.x, safe_left, safe_right)


func play_boss_death_spectacle():
	# 1) Heavy shake
	shake_intensity = 30.0
	vibrate(200)

	# 2) Slow motion
	Engine.time_scale = 0.3
	var slowmo_tween = create_tween()
	slowmo_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	slowmo_tween.tween_interval(1.2 * 0.3)
	slowmo_tween.tween_property(Engine, "time_scale", 1.0, 0.3)

	# 3) White flash overlay
	var flash_layer = CanvasLayer.new()
	flash_layer.layer = 95
	add_child(flash_layer)
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0.6)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.add_child(flash)
	var flash_tw = create_tween()
	flash_tw.tween_property(flash, "color:a", 0.0, 0.5)
	flash_tw.tween_callback(flash_layer.queue_free)

	# 4) Gold particle burst
	var center = enemy_sprite.global_position
	for i in range(12):
		var gold_lbl = Label.new()
		gold_lbl.text = ["$", "★", "✦", "♦", "●"].pick_random()
		var gold_ls := LabelSettings.new()
		gold_ls.font_size = randi_range(14, 24)
		gold_ls.font_color = [Color.GOLD, Color.YELLOW, Color(1.0, 0.8, 0.3)].pick_random()
		gold_ls.outline_size = 2
		gold_ls.outline_color = Color.BLACK
		gold_lbl.label_settings = gold_ls
		gold_lbl.global_position = center + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		gold_lbl.z_index = 100
		add_child(gold_lbl)

		var angle = randf() * TAU
		var dist = randf_range(80, 180)
		var target_pos = center + Vector2(cos(angle), sin(angle)) * dist
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(gold_lbl, "global_position", target_pos, randf_range(0.6, 1.0)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(gold_lbl, "modulate:a", 0.0, randf_range(0.8, 1.2)).set_delay(0.3)
		tw.tween_property(gold_lbl, "rotation_degrees", randf_range(-180, 180), 1.0)
		tw.chain().tween_callback(gold_lbl.queue_free)

	# 5) Enemy sprite death animation
	var death_tw = create_tween()
	death_tw.set_parallel(true)
	death_tw.tween_property(enemy_sprite, "scale", enemy_sprite.scale * 1.3, 0.15).set_trans(Tween.TRANS_QUAD)
	death_tw.chain().tween_property(enemy_sprite, "scale", enemy_sprite.scale * 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	death_tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.5).set_delay(0.15)


func _create_vignette_overlay():
	vignette_overlay = ColorRect.new()
	vignette_overlay.name = "VignetteOverlay"
	vignette_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette_overlay.modulate = Color(1, 1, 1, 0)

	var shader = Shader.new()
	shader.code = """
		shader_type canvas_item;
		uniform float intensity : hint_range(0.0, 1.0) = 0.7;
		uniform vec4 vignette_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			float dist = length(uv) * 2.0;
			float vignette = smoothstep(0.3, 1.2, dist) * intensity;
			COLOR = vec4(vignette_color.rgb, vignette);
		}
	"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	vignette_overlay.material = mat

	var vignette_layer = CanvasLayer.new()
	vignette_layer.name = "VignetteLayer"
	vignette_layer.layer = 100
	add_child(vignette_layer)
	vignette_layer.add_child(vignette_overlay)


func set_near_death(enabled: bool):
	if enabled == is_near_death:
		return
	is_near_death = enabled

	if vignette_tween:
		vignette_tween.kill()

	if enabled:
		vignette_tween = create_tween()
		vignette_tween.tween_property(vignette_overlay, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
		vignette_tween.tween_callback(_start_vignette_pulse)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").set_near_death_audio(true)
	else:
		vignette_tween = create_tween()
		vignette_tween.tween_property(vignette_overlay, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").set_near_death_audio(false)


func _start_vignette_pulse():
	if not is_near_death:
		return
	if vignette_tween:
		vignette_tween.kill()
	vignette_tween = create_tween().set_loops()
	vignette_tween.tween_property(vignette_overlay, "modulate:a", 0.4, 0.6).set_trans(Tween.TRANS_SINE)
	vignette_tween.tween_property(vignette_overlay, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


func clear_floating_texts():
	for node in get_tree().get_nodes_in_group("floating_text"):
		if is_instance_valid(node):
			node.queue_free()
	for node in get_tree().get_nodes_in_group("floating_combat_text"):
		if is_instance_valid(node):
			node.queue_free()
	if damage_container:
		for child in damage_container.get_children():
			if child.is_in_group("floating_combat_text"):
				child.queue_free()
			elif child is Label and child.get_script() != null:
				var child_script_path := str(child.get_script().resource_path)
				if child_script_path.ends_with("damage_label.gd"):
					child.queue_free()
	for child in get_children():
		if child is Label and child.get_script() != null:
			var script_path := str(child.get_script().resource_path)
			if script_path.ends_with("damage_label.gd"):
				child.queue_free()


func play_battle_fade_in():
	var overlay := ColorRect.new()
	overlay.color = Color.BLACK
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate.a = 0.32
	overlay.z_index = 110
	canvas_layer.add_child(overlay)
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.2)
	t.tween_callback(overlay.queue_free)


func play_stage_transition_flash():
	var overlay := ColorRect.new()
	overlay.color = Color(1, 1, 1, 0.0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 109
	canvas_layer.add_child(overlay)
	var t := create_tween()
	t.tween_property(overlay, "color:a", 0.45, 0.08)
	t.tween_property(overlay, "color:a", 0.0, 0.22)
	t.tween_callback(overlay.queue_free)


func animate_label(lbl: Control):
	if not lbl:
		return
	var original_mod := lbl.modulate
	UIAnimations.bounce_control(lbl, 1.18, 0.16)
	var flash := create_tween()
	flash.tween_property(lbl, "modulate", Color(1.0, 0.95, 0.45, 1.0), 0.06)
	flash.tween_property(lbl, "modulate", original_mod, 0.1)


func start_idle_animation():
	if idle_tween: idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var base_scale = enemy_sprite.scale
	idle_tween.tween_property(enemy_sprite, "scale", base_scale * 1.05, 1.2).set_trans(Tween.TRANS_SINE)
	idle_tween.tween_property(enemy_sprite, "scale", base_scale, 1.2).set_trans(Tween.TRANS_SINE)


func stop_idle_animation():
	if idle_tween:
		idle_tween.kill()


func vibrate(duration_ms: int = 50):
	if OS.has_feature("android") or OS.has_feature("ios"):
		Input.vibrate_handheld(duration_ms)
