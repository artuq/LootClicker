extends HBoxContainer
## Stage Progression Bar — aktualizuje 5 prebudowanych węzłów (N0..N4) ze sceny StageBar.tscn.
## Wygląd/rozmiary/odstępy edytujesz wizualnie w StageBar.tscn.
## Wołaj update_stage(current_stage) przy każdej zmianie etapu.

const RING_NORMAL := preload("res://assets/ui/stage/node_ring.png")
const RING_BOSS := preload("res://assets/ui/stage/node_ring_boss.png")
const THUMBS := {
	"jungle": preload("res://assets/ui/stage/thumb_jungle.png"),
	"temple": preload("res://assets/ui/stage/thumb_temple.png"),
	"desert": preload("res://assets/ui/stage/thumb_desert.png"),
	"frozen": preload("res://assets/ui/stage/thumb_frozen.png"),
}

const WINDOW := 2          # ±2 → 5 węzłów (środkowy = aktywny)
const ACTIVE_SCALE := 1.35

@onready var _nodes: Array = [$N0, $N1, $N2, $N3, $N4]


func update_stage(current: int) -> void:
	if _nodes.is_empty() or _nodes[0] == null:
		return
	for i in range(_nodes.size()):
		var s: int = current - WINDOW + i
		var node: Control = _nodes[i]
		if s < 1:
			node.visible = false
			continue
		node.visible = true
		node.get_node("Num").text = str(s)
		node.get_node("Thumb").texture = THUMBS.get(_biome_for(s), THUMBS["jungle"])
		node.get_node("Ring").texture = RING_BOSS if _is_boss(s) else RING_NORMAL
		var target := ACTIVE_SCALE if i == WINDOW else 1.0
		var tw := node.create_tween()
		tw.tween_property(node, "scale", Vector2.ONE * target, 0.18).set_trans(Tween.TRANS_QUAD)


func _biome_for(s: int) -> String:
	if s <= 14:
		return "jungle"
	if s <= 40:
		return "temple"
	if s <= 60:
		return "desert"
	return "frozen"


func _is_boss(s: int) -> bool:
	return s % 5 == 0
