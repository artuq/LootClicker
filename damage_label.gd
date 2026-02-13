extends Label

func _ready():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 80, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.chain().tween_callback(queue_free)
