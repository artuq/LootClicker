extends Node
class_name PlayerStats

signal gold_changed(amount)
signal health_changed(current, max_hp)
signal skills_updated 
signal item_added(item)
signal error_occurred(msg)
signal leveled_up(new_level) # New level up signal
signal xp_changed(current, required) # New XP change signal
signal resources_updated # Signal for skill tree
signal consumables_updated # New signal for potions

var gold: int = 25
var xp: int = 0
var level: int = 1
var xp_required: int = 20

# Atmospheric resources
var resources = {
	"bandages": 0,    # From Mummies, Squirrel, Monkey
	"venom": 0,       # From Snakes, Plant, Skeleton, Ghost
	"relic_shards": 0 # From Bosses, Golem
}

var consumables = {
	"hp_potion": 0
}

var max_hp: int = 100
# CHANGE: Start with full health
var current_hp: int = 100 

var str_lvl: int = 0
var speed_lvl: int = 0
var crit_lvl: int = 0
var greed_lvl: int = 0
var def_lvl: int = 0
var heal_count: int = 0

# New combat stats
var dodge_chance: float = 0.05 # 5% base
var block_chance: float = 0.0  # 0% base

var inventory: Array[GameItem] = []
var equipped_item: GameItem = null

# Cursed card debuffs
var active_curses: Array[Dictionary] = []  # [{id, stages_left, per_click_hp, per_sec_hp, ...}]
var heal_blocked: bool = false
var click_hp_cost: int = 0       # HP lost per click (Blood Price)
var poison_dps: int = 0          # HP lost per second (Toxic)
var thorns_percent: float = 0.0  # Damage reflected to enemy (Thorns)

var base_costs = {
	"str": 10, "speed": 15, "crit": 25, "greed": 10, "def": 15, "heal": 50, "hp": 30
}

func _ready():
	# UI signals will be handled by BattleManager after initialization/loading
	pass

func get_skill_cost(id: String) -> int:
	var lvl = 0
	match id:
		"str": lvl = str_lvl
		"speed": lvl = speed_lvl
		"crit": lvl = crit_lvl
		"greed": lvl = greed_lvl
		"def": lvl = def_lvl
		"heal": lvl = heal_count
		"hp": lvl = int((max_hp - 100) / 20.0)
	
	var multiplier = 1.7 if (id == "heal" or id == "hp") else 1.5
	return int(base_costs[id] * pow(multiplier, lvl))

# --- HEALING ---
func heal_player():
	if heal_blocked:
		error_occurred.emit("CURSED! No healing!")
		return
	# Heal only if there's something to heal
	if current_hp < max_hp:
		current_hp = max_hp
		heal_count += 1
		health_changed.emit(current_hp, max_hp)
		skills_updated.emit() # Refresh UI (price increases)

func use_consumable(type: String):
	if heal_blocked:
		error_occurred.emit("CURSED! No healing!")
		return false
	if consumables.get(type, 0) > 0:
		match type:
			"hp_potion":
				if current_hp < max_hp:
					# B: Potion heals 20% max HP or 30, whichever is bigger
					var heal_amount = max(30, int(max_hp * 0.2))
					current_hp = min(max_hp, current_hp + heal_amount)
					consumables[type] -= 1
					health_changed.emit(current_hp, max_hp)
					consumables_updated.emit()
					return true
	return false

# Called by BattleManager on each player click
func on_click_curse_cost():
	if click_hp_cost > 0 and current_hp > 0:
		current_hp = max(1, current_hp - click_hp_cost)
		health_changed.emit(current_hp, max_hp)

# Called by BattleManager timer for poison tick
func apply_poison_tick():
	if poison_dps > 0 and current_hp > 0:
		current_hp = max(1, current_hp - poison_dps)
		health_changed.emit(current_hp, max_hp)

func take_damage(amount: int) -> String:
	# Check for Dodge
	if randf() < dodge_chance:
		return "DODGED"
		
	# Check for Block (reduces damage by 50%)
	var final_dmg = amount
	var block_msg = ""
	if randf() < block_chance:
		final_dmg = int(amount * 0.5)
		block_msg = "BLOCKED "
		
	# C: Defense as % reduction (2% per level, cap 50%) instead of flat subtraction
	var def_reduction = min(0.50, def_lvl * 0.02)
	var dmg = max(1, int(final_dmg * (1.0 - def_reduction)))
	current_hp -= dmg
	if current_hp < 0: current_hp = 0
	health_changed.emit(current_hp, max_hp)        
	
	# Important: When we take damage, we must refresh the shop so the HEAL button enables!
	skills_updated.emit()
	return block_msg + str(dmg)
# --- REST OF FUNCTIONS UNCHANGED ---
func add_item(item: GameItem):
	inventory.append(item)
	item_added.emit(item)
	if equipped_item == null or item.damage_bonus > equipped_item.damage_bonus:
		equipped_item = item

func get_total_damage() -> int:
	# A: Base damage + STR, then multiply by % bonus from STR stacking
	var base = 1 + str_lvl
	if equipped_item: base += equipped_item.damage_bonus
	# Every 2 STR levels = +5% total damage (multiplicative scaling)
	var str_bonus = 1.0 + (str_lvl * 0.025)
	return int(base * str_bonus)

func get_crit_multiplier() -> float:
	# D: Crit damage scales with crit investment
	return 2.0 + (crit_lvl * 0.02)

func get_attack_speed() -> float:
	# E: Soft cap with diminishing returns instead of hard wall
	# Formula: 1.0 / (1.0 + speed_lvl * 0.08) — never reaches 0, smooth curve
	# speed_lvl 0 = 1.0s, 5 = 0.71s, 10 = 0.56s, 16 = 0.44s, 25 = 0.33s, 50 = 0.2s
	return max(0.15, 1.0 / (1.0 + speed_lvl * 0.08))

func is_critical_hit() -> bool:
	# Cap crit chance at 80%
	return randf() < min(0.8, crit_lvl * 0.01)

func gain_gold(amount: int):
	gold += int(amount * (1.0 + (greed_lvl * 0.05)))
	gold_changed.emit(gold)

func add_resource(type: String, amount: int):
	if resources.has(type):
		resources[type] += amount
		resources_updated.emit()

func trigger_error(msg: String):
	error_occurred.emit(msg)

func gain_xp(amount: int):
	xp += amount
	xp_changed.emit(xp, xp_required)  # Emit signal for every XP gain
	if xp >= xp_required:
		xp -= xp_required
		level += 1
		xp_required = int(xp_required * 1.3) # F: Smoother XP curve (was 1.4)
		leveled_up.emit(level)

# === Cursed Card System ===
func apply_curse(curse: Dictionary):
	var c = curse.duplicate()
	active_curses.append(c)
	_recalculate_curse_effects()
	print("CURSE APPLIED: %s (stages: %d)" % [c.get("id", "?"), c.get("stages", -1)])

func on_stage_advance():
	# Tick down stage-based curses
	var to_remove = []
	for i in range(active_curses.size()):
		if active_curses[i].has("stages") and active_curses[i].stages > 0:
			active_curses[i].stages -= 1
			if active_curses[i].stages <= 0:
				to_remove.append(i)
	# Remove expired (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		print("CURSE EXPIRED: %s" % active_curses[to_remove[i]].get("id", "?"))
		active_curses.remove_at(to_remove[i])
	_recalculate_curse_effects()

func _recalculate_curse_effects():
	# Reset all curse effects
	heal_blocked = false
	click_hp_cost = 0
	poison_dps = 0
	thorns_percent = 0.0
	
	for c in active_curses:
		match c.get("id", ""):
			"curse_berserker":
				heal_blocked = true
			"curse_blood":
				click_hp_cost += 3
			"curse_toxic":
				poison_dps += 2
			"curse_thorns":
				poison_dps += 1  # Slow bleed
				thorns_percent += 0.3  # 30% reflect
			"curse_glass":
				pass  # One-time effect applied at selection
			"curse_frenzy":
				pass  # One-time effect applied at selection

func get_active_curse_names() -> Array:
	var names = []
	for c in active_curses:
		names.append(c.get("id", "unknown"))
	return names
