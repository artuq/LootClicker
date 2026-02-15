extends Control

@onready var points_label = %PointsLabel
var player: PlayerStats

func setup(p_ref: PlayerStats):
	player = p_ref
	
	# Podpinamy odświeżanie
	if not player.skills_updated.is_connected(update_ui):
		player.skills_updated.connect(update_ui)
	if not player.resources_updated.is_connected(update_ui):
		player.resources_updated.connect(update_ui)
		
	# Inicjalizujemy wszystkie węzły
	for node in %TreeLayout.get_children():
		if node is SkillNode:
			node.setup(player)
			if not node.pressed.is_connected(_on_node_pressed.bind(node)):
				node.pressed.connect(_on_node_pressed.bind(node))
			
	update_ui()

func update_ui():
	if player == null: return
	
	points_label.text = "Resources: %d Bandages, %d Venom, %d Shards" % [
		player.resources["bandages"], 
		player.resources["venom"], 
		player.resources["relic_shards"]
	]
	
	for node in %TreeLayout.get_children():
		if node is SkillNode:
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
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_error_sound()

func _on_back_button_pressed():
	# Powrót do gry
	visible = false
	get_tree().paused = false
	# Jeśli chcemy przeładować scenę walki, używamy change_scene, 
	# ale tu po prostu ukrywamy nakładkę.
