extends ScrollContainer

var player: PlayerStats
@onready var points_label = %PointsLabel

func setup(p_ref: PlayerStats):
	player = p_ref
	
	# Podpinamy odświeżanie
	if not player.skills_updated.is_connected(update_ui):
		player.skills_updated.connect(update_ui)
	if not player.resources_updated.is_connected(update_ui):
		player.resources_updated.connect(update_ui)
		
	# Inicjalizujemy wszystkie węzły umiejętności wewnątrz
	for node in find_children("*", "SkillNode", true):
		node.setup(player)
		if not node.pressed.is_connected(_on_node_pressed.bind(node)):
			node.pressed.connect(_on_node_pressed.bind(node))
			
	update_ui()

func _draw():
	# Rysujemy linie łączące węzły
	for node in find_children("*", "SkillNode", true):
		if node.requirement_skill != "":
			var req_node = _find_skill_node(node.requirement_skill)
			if req_node:
				var start = req_node.position + req_node.size / 2
				var end = node.position + node.size / 2
				draw_line(start, end, Color(0.4, 0.3, 0.2), 4.0)

func _find_skill_node(id: String) -> SkillNode:
	for node in find_children("*", "SkillNode", true):
		if node.skill_id == id:
			return node
	return null

func update_ui():
	if player == null or points_label == null: return
	queue_redraw() # Odśwież linie
	
	points_label.text = "Resources: %d Bandages, %d Venom, %d Shards" % [
		player.resources["bandages"], 
		player.resources["venom"], 
		player.resources["relic_shards"]
	]
	
	for node in find_children("*", "SkillNode", true):
		node.update_state()

func _on_node_pressed(node: SkillNode):
	var cost = player.get_skill_cost(node.skill_id)
	var res_id = node._get_res_id()
	
	if player.resources[res_id] >= cost:
		player.resources[res_id] -= cost
		match node.skill_id:
			"str": player.str_lvl += 1
			"crit": player.crit_lvl += 1
			"greed": player.greed_lvl += 1
			"speed": player.speed_lvl += 1
			"def": player.def_lvl += 1
		
		player.resources_updated.emit()
		player.skills_updated.emit()
	else:
		player.error_occurred.emit("NOT ENOUGH %s!" % res_id.to_upper())
