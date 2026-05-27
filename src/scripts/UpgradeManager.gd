extends Node
class_name UpgradeManager

# Definitions for possible upgrades (Cards)
var available_cards = [
	{"id": "str", "name": "Brawn", "flavor_name": "Jungle Protein", "desc": "STR +2, DMG +5%", "flavor_desc": "Muscles grow just by glaring at the locals.", "stat_short": "STR +2, DMG +5%", "icon": "res://assets/ui/cards/card_str.png"},
	{"id": "crit", "name": "Precision", "flavor_name": "Dead-eye", "desc": "Crit +5%, Crit DMG up", "flavor_desc": "Joana aims exactly where it hurts the most.", "stat_short": "Crit +5%, C.DMG up", "icon": "res://assets/ui/cards/card_crit.png"},
	{"id": "speed", "name": "Agility", "flavor_name": "Caffeine Shot!", "desc": "Attack Speed up", "flavor_desc": "Whipping like crazy! No time for coffee breaks!", "stat_short": "Atk Speed up", "icon": "res://assets/ui/cards/card_speed.png"},
	{"id": "hp", "name": "Vitality", "flavor_name": "Thick Skin", "desc": "Max HP +20, Full Heal", "flavor_desc": "Years in the jungle harden the body against bites.", "stat_short": "Max HP +20, Heal", "icon": "res://assets/ui/cards/card_hp.png"},
	{"id": "gold", "name": "Greed", "flavor_name": "Deep Pockets", "desc": "Gold Gain +15%", "flavor_desc": "Gold coins somehow find their own way into the pouch.", "stat_short": "Gold +15%", "icon": "res://assets/ui/cards/card_gold.png"},
	{"id": "def", "name": "Armor", "flavor_name": "Heavy Fedora", "desc": "Defense +2% DMG reduction", "flavor_desc": "Deflects ricochets, stones, and enemy insults.", "stat_short": "Def +2%", "icon": "res://assets/ui/cards/card_def.png"},
	{"id": "dodge", "name": "Evasion", "flavor_name": "Cat Reflexes", "desc": "Dodge Chance +3%", "flavor_desc": "Hard to hit someone who trips over their own feet.", "stat_short": "Dodge +3%", "icon": "res://assets/ui/cards/card_crit.png"},
	{"id": "block", "name": "Bulwark", "flavor_name": "Leather Whip", "desc": "Block Chance +5%", "flavor_desc": "Blocking tiger fangs with a leather strap? Hold my beer.", "stat_short": "Block +5%", "icon": "res://assets/ui/cards/card_hp.png"}
]

# Cursed cards — high risk, high reward
var cursed_cards = [
	{"id": "curse_berserker", "name": "Berserker", "flavor_name": "Battle Trance", "desc": "STR +8\nNo healing for 5 stages!", "flavor_desc": "Pain? No time for pain! A true bloodbath!", "stat_short": "STR +8\nNO HEAL (5 stages)", "icon": "res://assets/ui/cards/card_curse_berserker.png", "cursed": true},
	{"id": "curse_glass", "name": "Glass Cannon", "flavor_name": "Glass Jaw", "desc": "Crit +20%\nMax HP halved!", "flavor_desc": "Your one punch decides everything. Theirs too.", "stat_short": "Crit +20%\nMAX HP -50%", "icon": "res://assets/ui/cards/card_curse_glass.png", "cursed": true},
	{"id": "curse_blood", "name": "Blood Price", "flavor_name": "Curse of Greed", "desc": "Gold x2\n-3 HP per click!", "flavor_desc": "This gold smells of blood. Yours, actually.", "stat_short": "Gold x2\n-3 HP/Tap", "icon": "res://assets/ui/cards/card_curse_blood.png", "cursed": true},
	{"id": "curse_frenzy", "name": "Frenzy", "flavor_name": "Suicidal Charge", "desc": "Speed x2\nDefense = 0!", "flavor_desc": "Dropping armor to run faster. What could go wrong?", "stat_short": "Speed x2\nDEF = 0", "icon": "res://assets/ui/cards/card_curse_frenzy.png", "cursed": true},
	{"id": "curse_toxic", "name": "Toxic", "flavor_name": "Poisoned Blade", "desc": "STR +5, Crit +10%\nPoison: -2 HP/s!", "flavor_desc": "Venom in your veins. Power and pain.", "stat_short": "STR +5, Crit +10%\nPoison -2 HP/s", "icon": "res://assets/ui/cards/card_curse_toxic.png", "cursed": true},
	{"id": "curse_thorns", "name": "Thorns", "flavor_name": "Armor of Thorns", "desc": "Reflect 30% dmg\nBleed: -1 HP/s!", "flavor_desc": "Thorns out. Blood in. Even trade.", "stat_short": "Reflect 30%\nBleed -1 HP/s", "icon": "res://assets/ui/cards/card_curse_thorns.png", "cursed": true},
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
		"str": player.card_str += 2
		"crit": player.card_crit += 5
		"speed": player.card_speed += 2
		"hp":
			player.card_hp += 1
			player.max_hp += 20
			player.current_hp = player.max_hp
		"gold": player.card_greed += 3
		"def": player.card_def += 1
		"dodge": player.dodge_chance += 0.03
		"block": player.block_chance += 0.05
		# === Cursed Cards ===
		"curse_berserker":
			player.card_str += 8
			player.apply_curse({"id": "curse_berserker", "stages": 5})
		"curse_glass":
			player.card_crit += 20
			player.max_hp = int(player.max_hp * 0.5)
			player.current_hp = min(player.current_hp, player.max_hp)
			player.apply_curse({"id": "curse_glass", "stages": -1})
		"curse_blood":
			player.card_greed += 15
			player.apply_curse({"id": "curse_blood", "stages": -1})
		"curse_frenzy":
			player.card_speed += player.card_speed + player.speed_lvl + 10
			player.def_lvl = 0
			player.card_def = 0
			player.apply_curse({"id": "curse_frenzy", "stages": 5})
		"curse_toxic":
			player.card_str += 5
			player.card_crit += 10
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
