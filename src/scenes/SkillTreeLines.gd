extends Control
## Draws tree-maps style connection lines (with shadow + arrow) between SkillNodes.

var _connections: Array = []   # [{from: SkillNode, to: SkillNode}]

func setup(skill_map: Dictionary) -> void:
	# Define directed edges  parent → child
	var edges := [
		["str",  "greed"],
		["hp",   "crit"],
		["greed","speed"],
		["crit", "def"],
	]
	_connections.clear()
	for e in edges:
		if skill_map.has(e[0]) and skill_map.has(e[1]):
			_connections.append({"from": skill_map[e[0]], "to": skill_map[e[1]]})
	queue_redraw()

func refresh() -> void:
	queue_redraw()

# ── drawing ──────────────────────────────────────────────────────────
func _draw() -> void:
	for conn in _connections:
		var from_node: SkillNode = conn.from
		var to_node: SkillNode   = conn.to
		var from_c := from_node.position + from_node.size * 0.5
		var to_c   := to_node.position   + to_node.size   * 0.5
		var col    := _line_color(from_node, to_node)
		var w      := 3.0 if _is_edge_active(from_node, to_node) else 2.0

		# shadow
		draw_line(from_c + Vector2(1, 1), to_c + Vector2(1, 1),
				  Color(0, 0, 0, 0.35), w + 1.0, true)
		# main line
		draw_line(from_c, to_c, col, w, true)
		# arrowhead
		_draw_arrow(from_c, to_c, col)

func _draw_arrow(from: Vector2, to: Vector2, color: Color) -> void:
	var dir  := (to - from).normalized()
	var tip  := to - dir * 36.0          # just outside the node circle
	var perp := Vector2(-dir.y, dir.x)
	var s    := 7.0
	var pts  := PackedVector2Array([
		tip + dir * s,
		tip - dir * 0.5 * s + perp * s,
		tip - dir * 0.5 * s - perp * s,
	])
	draw_colored_polygon(pts, color)

# ── helpers ──────────────────────────────────────────────────────────
func _is_edge_active(from_node: SkillNode, to_node: SkillNode) -> bool:
	if from_node.player == null:
		return false
	return from_node._get_player_skill_lvl() >= to_node.requirement_level

func _line_color(from_node: SkillNode, to_node: SkillNode) -> Color:
	if from_node.player == null:
		return Color(0.3, 0.3, 0.3, 0.5)
	var to_lvl   := int(to_node._get_player_skill_lvl())
	var from_lvl := int(from_node._get_player_skill_lvl())
	if to_lvl >= to_node.max_level:
		return Color(1.0, 0.84, 0.0, 1.0)      # gold  – completed
	elif from_lvl >= to_node.requirement_level:
		return Color(0.3, 1.0, 0.5, 0.9)        # green – unlocked
	else:
		return Color(0.4, 0.4, 0.4, 0.5)        # gray  – locked
