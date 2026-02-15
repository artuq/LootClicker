extends Label

func _ready():
	# Add random rotation for "juice"
	rotation_degrees = randf_range(-15.0, 15.0)
	pivot_offset = size / 2
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 80, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.chain().tween_callback(queue_free)
