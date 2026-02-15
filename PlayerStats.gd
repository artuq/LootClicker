extends Node
class_name PlayerStats

signal gold_changed(amount)
signal health_changed(current, max_hp)
signal skills_updated 
signal item_added(item)
signal error_occurred(msg)
signal leveled_up(new_level) # Nowy sygnał awansu
signal resources_updated # Sygnał dla drzewka umiejętności
signal consumables_updated # Nowy sygnał dla mikstur

var gold: int = 25
var xp: int = 0
var level: int = 1
var xp_required: int = 20

# Surowce klimatyczne
var resources = {
	"bandages": 0,    # Z Mumii
	"venom": 0,       # Z Węży
	"relic_shards": 0 # Z Bossów
}

var consumables = {
	"hp_potion": 0
}

var max_hp: int = 100
# ZMIANA: Startujemy z pełnym życiem
var current_hp: int = 100 

var str_lvl: int = 0
var speed_lvl: int = 0
var crit_lvl: int = 0
var greed_lvl: int = 0
var def_lvl: int = 0
var heal_count: int = 0

var inventory: Array[GameItem] = []
var equipped_item: GameItem = null

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
		"hp": lvl = int((max_hp - 100) / 20)
	
	var multiplier = 1.7 if (id == "heal" or id == "hp") else 1.5
	return int(base_costs[id] * pow(multiplier, lvl))

# --- LECZENIE ---
func heal_player():
	# Lecz tylko jeśli jest co leczyć
	if current_hp < max_hp:
		current_hp = max_hp
		heal_count += 1
		health_changed.emit(current_hp, max_hp)
		skills_updated.emit() # Odśwież UI (cena wzrośnie)

func use_consumable(type: String):
	if consumables.get(type, 0) > 0:
		match type:
			"hp_potion":
				if current_hp < max_hp:
					current_hp = min(max_hp, current_hp + 30)
					consumables[type] -= 1
					health_changed.emit(current_hp, max_hp)
					consumables_updated.emit()
					return true
	return false

func take_damage(amount: int):
	var dmg = max(1, amount - def_lvl)
	current_hp -= dmg
	if current_hp < 0: current_hp = 0
	health_changed.emit(current_hp, max_hp)
	
	# Ważne: Kiedy obrywamy, musimy odświeżyć sklep, żeby przycisk HEAL się włączył!
	skills_updated.emit()

# --- RESZTA FUNKCJI BEZ ZMIAN ---
func add_item(item: GameItem):
	inventory.append(item)
	item_added.emit(item)
	if equipped_item == null or item.damage_bonus > equipped_item.damage_bonus:
		equipped_item = item

func get_total_damage() -> int:
	var base = 1 + str_lvl
	if equipped_item: base += equipped_item.damage_bonus
	return base

func get_attack_speed() -> float:
	return max(0.2, 1.0 - (speed_lvl * 0.05))

func is_critical_hit() -> bool:
	return randf() < (crit_lvl * 0.01)

func gain_gold(amount: int):
	gold += int(amount * (1.0 + (greed_lvl * 0.05)))
	gold_changed.emit(gold)

func gain_xp(amount: int):
	xp += amount
	if xp >= xp_required:
		xp -= xp_required
		level += 1
		xp_required = int(xp_required * 1.4) # Skalowanie trudności levelowania
		leveled_up.emit(level)
