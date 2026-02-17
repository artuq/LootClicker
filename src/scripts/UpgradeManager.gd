extends Node
class_name UpgradeManager

# Definitions for possible upgrades (Cards)
var available_cards = [
	{"id": "str", "name": "Brawn", "desc": "STR +2, DMG +5%", "icon": "res://assets/ui/cards/card_str.png"},
	{"id": "crit", "name": "Precision", "desc": "Crit +5%, Crit DMG up", "icon": "res://assets/ui/cards/card_crit.png"},
	{"id": "speed", "name": "Agility", "desc": "Attack Speed up", "icon": "res://assets/ui/cards/card_speed.png"},
	{"id": "hp", "name": "Vitality", "desc": "Max HP +20, Full Heal", "icon": "res://assets/ui/cards/card_hp.png"},
	{"id": "gold", "name": "Greed", "desc": "Gold Gain +15%", "icon": "res://assets/ui/cards/card_gold.png"},
	{"id": "def", "name": "Armor", "desc": "Defense +2% DMG reduction", "icon": "res://assets/ui/cards/card_def.png"},
	{"id": "dodge", "name": "Evasion", "desc": "Dodge Chance +3%", "icon": "res://assets/ui/cards/card_crit.png"},
	{"id": "block", "name": "Bulwark", "desc": "Block Chance +5%", "icon": "res://assets/ui/cards/card_hp.png"}
]

# Cursed cards — high risk, high reward
var cursed_cards = [
	{"id": "curse_berserker", "name": "Berserker", "desc": "STR +8\nNo healing for 5 stages!", "icon": "res://assets/ui/cards/card_curse_berserker.png", "cursed": true},
	{"id": "curse_glass", "name": "Glass Cannon", "desc": "Crit +20%\nMax HP halved!", "icon": "res://assets/ui/cards/card_curse_glass.png", "cursed": true},
	{"id": "curse_blood", "name": "Blood Price", "desc": "Gold x2\n-3 HP per click!", "icon": "res://assets/ui/cards/card_curse_blood.png", "cursed": true},
	{"id": "curse_frenzy", "name": "Frenzy", "desc": "Speed x2\nDefense = 0!", "icon": "res://assets/ui/cards/card_curse_frenzy.png", "cursed": true},
	{"id": "curse_toxic", "name": "Toxic", "desc": "STR +5, Crit +10%\nPoison: -2 HP/s!", "icon": "res://assets/ui/cards/card_curse_toxic.png", "cursed": true},
	{"id": "curse_thorns", "name": "Thorns", "desc": "Reflect 30% dmg\nBleed: -1 HP/s!", "icon": "res://assets/ui/cards/card_curse_thorns.png", "cursed": true},
]

const CURSE_CHANCE = 0.25 # 25% chance to include a cursed card in options

func get_random_options(count: int = 3) -> Array:
	var options = available_cards.duplicate()
	options.shuffle()
	var result = options.slice(0, count)
	
	# Roll for cursed card — replace one normal card
	if randf() < CURSE_CHANCE:
		var curse_pool = cursed_cards.duplicate()
		curse_pool.shuffle()
		result[randi() % result.size()] = curse_pool[0]
	
	return result

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
		"dodge": player.dodge_chance += 0.03
		"block": player.block_chance += 0.05
		# === Cursed Cards ===
		"curse_berserker":
			player.str_lvl += 8
			player.apply_curse({"id": "curse_berserker", "stages": 5})
		"curse_glass":
			player.crit_lvl += 20
			player.max_hp = int(player.max_hp * 0.5)
			player.current_hp = min(player.current_hp, player.max_hp)
			player.apply_curse({"id": "curse_glass", "stages": -1})  # Permanent
		"curse_blood":
			player.greed_lvl += 15  # Huge gold boost
			player.apply_curse({"id": "curse_blood", "stages": -1})
		"curse_frenzy":
			player.speed_lvl += player.speed_lvl + 10  # Double+ speed
			player.def_lvl = 0
			player.apply_curse({"id": "curse_frenzy", "stages": 5})
		"curse_toxic":
			player.str_lvl += 5
			player.crit_lvl += 10
			player.apply_curse({"id": "curse_toxic", "stages": 8})
		"curse_thorns":
			player.apply_curse({"id": "curse_thorns", "stages": 10})
		_:
			print("WARNING: Unknown upgrade ID: %s" % upgrade_id)
			return

	print("DEBUG: Applied upgrade - %s" % upgrade_id)
	player.health_changed.emit(player.current_hp, player.max_hp)
	player.gold_changed.emit(player.gold)
	player.skills_updated.emit()
