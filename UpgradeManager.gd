extends Node
class_name UpgradeManager

# Definicje możliwych ulepszeń (Karty)
var available_cards = [
	{"id": "str", "name": "Brawn", "desc": "Strength +2", "icon": "sword"},
	{"id": "crit", "name": "Precision", "desc": "Crit Chance +5%", "icon": "aim"},
	{"id": "speed", "name": "Agility", "desc": "Attack Speed +10%", "icon": "wing"},
	{"id": "hp", "name": "Vitality", "desc": "Max HP +20", "icon": "heart"},
	{"id": "gold", "name": "Greed", "desc": "Gold Gain +15%", "icon": "coin"},
	{"id": "def", "name": "Armor", "desc": "Defense +1", "icon": "shield"}
]

func get_random_options(count: int = 3) -> Array:
	var options = available_cards.duplicate()
	options.shuffle()
	return options.slice(0, count)

func apply_upgrade(player: PlayerStats, upgrade_id: String):
	match upgrade_id:
		"str": player.str_lvl += 2
		"crit": player.crit_lvl += 5
		"speed": player.speed_lvl += 2
		"hp": 
			player.max_hp += 20
			player.current_hp = player.max_hp # Leczymy przy okazji
		"gold": player.greed_lvl += 3
		"def": player.def_lvl += 1
	
	player.health_changed.emit(player.current_hp, player.max_hp)
	player.gold_changed.emit(player.gold)
	player.skills_updated.emit()
