extends Button
class_name SkillNode

@export var skill_id: String = "str"
@export var currency_type: String = "resource" # "gold" lub "resource"
@export var max_level: int = 10
@export var requirement_skill: String = ""
@export var requirement_level: int = 0
@export var icon_texture: Texture2D

var player: PlayerStats

func setup(p_ref: PlayerStats):
	player = p_ref
	if icon_texture:
		icon = icon_texture
		expand_icon = true
	update_state()

func update_state():
	if player == null: return
	
	var current_lvl = _get_player_skill_lvl()
	var cost = player.get_skill_cost(skill_id)
	
	var can_afford = false
	if currency_type == "gold":
		can_afford = player.gold >= cost
	else:
		var res_id = _get_res_id()
		can_afford = player.resources[res_id] >= cost
	
	var req_met = true
	if requirement_skill != "":
		var req_lvl = _get_player_skill_lvl(requirement_skill)
		req_met = req_lvl >= requirement_level
	
	visible = req_met or (requirement_skill == "")
	disabled = not (req_met and can_afford and current_lvl < max_level)
	
	if current_lvl >= max_level:
		modulate = Color.GOLD
		text = "MAX"
	elif not req_met:
		modulate = Color(0.3, 0.3, 0.3, 0.8)
		text = "LOCKED"
	else:
		modulate = Color.WHITE
		var suffix = "G" if currency_type == "gold" else _get_res_id().substr(0,1).to_upper()
		text = "L%d\n%d%s" % [current_lvl, cost, suffix]

func _get_player_skill_lvl(id: String = ""):
	var target_id = id if id != "" else skill_id
	match target_id:
		"str": return player.str_lvl
		"crit": return player.crit_lvl
		"greed": return player.greed_lvl
		"speed": return player.speed_lvl
		"def": return player.def_lvl
		"hp": return (player.max_hp - 100) / 20 # Przykładowe wyliczenie poziomu HP
	return 0

func _get_res_id():
	match skill_id:
		"str", "greed": return "bandages"
		"crit", "speed": return "venom"
		"def": return "relic_shards"
	return "bandages"
