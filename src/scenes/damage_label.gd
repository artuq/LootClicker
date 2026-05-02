extends Label

var _is_crit: bool = false
var _arc_direction: float = 0.0

func _ready():
	add_to_group("floating_text")
	add_to_group("floating_combat_text")
	pivot_offset = size / 2
	
	# Determine arc direction (left or right of center)
	_arc_direction = [-1.0, 1.0].pick_random()
	
	if _is_crit:
		# Crits: bigger, orange, wider arc
		scale = Vector2(1.6, 1.6)
		rotation_degrees = randf_range(-20.0, 20.0)
		var tween = create_tween()
		tween.set_parallel(true)
		# Parabolic arc: horizontal drift + gravity-like vertical
		tween.tween_property(self, "position:x", position.x + _arc_direction * randf_range(40, 70), 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", position.y - 60, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(self, "position:y", position.y + 20, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate:a", 0.0, 1.2)
		# Scale punch: start big, settle down
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_ELASTIC)
		tween.chain().tween_callback(queue_free)
	else:
		# Normal hits: gentle arc upward
		rotation_degrees = randf_range(-12.0, 12.0)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position:x", position.x + _arc_direction * randf_range(15, 35), 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position:y", position.y - 45, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(0.3)
		tween.tween_property(self, "scale", Vector2(0.8, 0.8), 1.0).set_trans(Tween.TRANS_SINE)
		tween.chain().tween_callback(queue_free)
