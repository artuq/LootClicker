extends Node
class_name PlayerStats

signal gold_changed(amount)
signal health_changed(current, max_hp)
signal skills_updated # Sygnał odświeżający ceny w sklepie
signal item_added(item)
signal error_occurred(msg) # Nowy sygnał dla błędów (np. brak złota)

var gold: int = 25
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
	"str": 10, "speed": 15, "crit": 40, "greed": 20, "def": 15, "heal": 5
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
	
	var multiplier = 1.5 if id == "heal" else 1.3
	return int(base_costs[id] * pow(multiplier, lvl))

# --- LECZENIE ---
func heal_player():
	# Lecz tylko jeśli jest co leczyć
	if current_hp < max_hp:
		current_hp = max_hp
		heal_count += 1
		health_changed.emit(current_hp, max_hp)
		skills_updated.emit() # Odśwież UI (cena wzrośnie)

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
