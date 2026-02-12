extends Node
class_name PlayerStats

# SIGNALS
signal health_changed(current_hp, max_hp)
signal gold_changed(new_amount)
signal xp_changed(current, total)

# STATS
var max_hp: int = 100
var current_hp: int = 100
var base_damage: int = 5
var gold: int = 0

# PROGRESSION
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 50

# INVENTORY
var inventory: Array[GameItem] = []
var equipped_weapon: GameItem = null

func _ready():
	# Update UI at the very start
	health_changed.emit(current_hp, max_hp)
	gold_changed.emit(gold)
	xp_changed.emit(current_xp, xp_to_next_level)

# Total damage = player strength + weapon bonus
func get_total_damage() -> int:
	var total = base_damage
	if equipped_weapon != null:
		total += equipped_weapon.damage_bonus
	return total

func take_damage(amount: int):
	current_hp -= amount
	if current_hp < 0: current_hp = 0
	health_changed.emit(current_hp, max_hp)

func gain_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)

func gain_xp(amount: int):
	current_xp += amount
	while current_xp >= xp_to_next_level:
		_level_up()
	xp_changed.emit(current_xp, xp_to_next_level)

func add_item_to_inventory(item: GameItem):
	inventory.append(item)
	print("New item in backpack: ", item.item_name)

func _level_up():
	current_xp -= xp_to_next_level
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)
	base_damage += 2
	max_hp += 10
	current_hp = max_hp
	print("--- LEVEL UP! Current Level: ", level, " ---")
