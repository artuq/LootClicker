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
	animate_open()

func animate_open():
	# Ustawiamy punkt obrotu na środek dla ładnego skalowania
	pivot_offset = size / 2
	scale = Vector2.ZERO
	modulate.a = 0
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func update_ui():
	if player == null: return
	
	points_label.text = "Gold: %d | Bandages: %d, Venom: %d, Shards: %d" % [
		player.gold,
		player.resources["bandages"], 
		player.resources["venom"], 
		player.resources["relic_shards"]
	]
	
	for node in %TreeLayout.get_children():
		if node is SkillNode:
			node.update_state()

func _on_node_pressed(node: SkillNode):
	var cost = player.get_skill_cost(node.skill_id)
	
	if node.currency_type == "gold":
		if player.gold >= cost:
			player.gold -= cost
			_apply_skill(node.skill_id)
			player.gold_changed.emit(player.gold)
		else:
			_play_error()
	else:
		var res_id = node._get_res_id()
		if player.resources[res_id] >= cost:
			player.resources[res_id] -= cost
			_apply_skill(node.skill_id)
			player.resources_updated.emit()
		else:
			_play_error()

func _apply_skill(id: String):
	match id:
		"str": player.str_lvl += 1
		"crit": player.crit_lvl += 1
		"greed": player.greed_lvl += 1
		"speed": player.speed_lvl += 1
		"def": player.def_lvl += 1
		"hp": 
			player.max_hp += 20
			player.current_hp = player.max_hp
	player.skills_updated.emit()

func _play_error():
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_error_sound()

func _on_back_button_pressed():
	# Animacja wyjścia
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	tween.chain().finished.connect(func():
		get_tree().paused = false
		queue_free()
	)
