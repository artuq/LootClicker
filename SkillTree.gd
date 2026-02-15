extends ScrollContainer

var player: PlayerStats

@onready var points_label = %PointsLabel
@onready var btn_str = %BtnStr
@onready var btn_crit = %BtnCrit
@onready var btn_gold = %BtnGold
@onready var btn_spd = %BtnSpd
@onready var btn_def = %BtnDef
@onready var btn_heal = %BtnHeal

func setup(p_ref: PlayerStats):
	player = p_ref
	if not player.skills_updated.is_connected(update_ui):
		player.skills_updated.connect(update_ui)
	if not player.gold_changed.is_connected(func(_g): update_ui()):
		player.gold_changed.connect(func(_g): update_ui())
	update_ui()

func update_ui():
	if player == null or not is_node_ready() or points_label == null: return
	
	points_label.text = "Resources: %d B, %d V, %d S" % [
		player.resources["bandages"], 
		player.resources["venom"], 
		player.resources["relic_shards"]
	]
	
	_upd(btn_str, "str", "Strength", player.str_lvl, "bandages")
	_upd(btn_crit, "crit", "Crit Chance", player.crit_lvl, "venom")
	_upd(btn_gold, "greed", "Greed", player.greed_lvl, "bandages")
	_upd(btn_spd, "speed", "Attack Speed", player.speed_lvl, "venom")
	_upd(btn_def, "def", "Defense", player.def_lvl, "relic_shards")

func _upd(btn, id, text, lvl, res_id):
	if btn:
		var cost = player.get_skill_cost(id)
		var current_res = player.resources[res_id]
		btn.text = "%s (L%d)\n%d %s" % [text, lvl, cost, res_id.capitalize()]
		btn.disabled = current_res < cost

func _buy(id: String):
	# Mapowanie ulepszenia na surowiec
	var res_map = {
		"str": "bandages",
		"crit": "venom",
		"greed": "bandages",
		"speed": "venom",
		"def": "relic_shards"
	}
	var res_id = res_map[id]
	var cost = player.get_skill_cost(id)
	
	if player.resources[res_id] >= cost:
		player.resources[res_id] -= cost
		match id:
			"str": player.str_lvl += 1
			"crit": player.crit_lvl += 1
			"greed": player.greed_lvl += 1
			"speed": player.speed_lvl += 1
			"def": player.def_lvl += 1
		
		player.resources_updated.emit()
		player.skills_updated.emit()
	else:
		player.error_occurred.emit("NOT ENOUGH %s!" % res_id.to_upper())
