extends RefCounted
class_name UIAnimations

static func fade_in(node: CanvasItem, duration: float = 0.25) -> Tween:
	node.modulate.a = 0.0
	var t := node.create_tween()
	t.tween_property(node, "modulate:a", 1.0, duration)
	return t

static func fade_out(node: CanvasItem, duration: float = 0.2) -> Tween:
	var t := node.create_tween()
	t.tween_property(node, "modulate:a", 0.0, duration)
	return t

static func scale_in(node: Control, duration: float = 0.3) -> Tween:
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2(0.85, 0.85)
	node.modulate.a = 0.0
	var t := node.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", Vector2.ONE, duration)
	t.tween_property(node, "modulate:a", 1.0, duration * 0.7)
	return t

static func slide_in_from_bottom(node: Control, duration: float = 0.32, offset: float = 52.0) -> Tween:
	var original_y := node.position.y
	node.position.y += offset
	node.modulate.a = 0.0
	var t := node.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "position:y", original_y, duration)
	t.tween_property(node, "modulate:a", 1.0, duration * 0.75)
	return t

static func slide_out_to_bottom(node: Control, duration: float = 0.2, offset: float = 44.0) -> Tween:
	var t := node.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(node, "position:y", node.position.y + offset, duration)
	t.tween_property(node, "modulate:a", 0.0, duration * 0.85)
	return t

static func bounce_control(node: Control, scale_peak: float = 1.18, duration: float = 0.16) -> Tween:
	var t := node.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", Vector2(scale_peak, scale_peak), duration * 0.45)
	t.tween_property(node, "scale", Vector2.ONE, duration * 0.55)
	return t
