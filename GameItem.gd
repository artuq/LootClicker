extends Resource
class_name GameItem

# --- ITEM DEFINITION ---
# This script is a template for EVERY item in the game.

enum ItemType { WEAPON, ARMOR }
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var id: String = "item_000"
@export var item_name: String = "Unknown Item"
@export var type: ItemType = ItemType.WEAPON
@export var rarity: Rarity = Rarity.COMMON

# Stats
@export var damage_bonus: int = 0
@export var price: int = 10

# Function to get a nice text description
func get_description() -> String:
	var text = item_name + " [" + Rarity.keys()[rarity] + "]"
	if damage_bonus > 0:
		text += "\nDMG: +" + str(damage_bonus)
	return text
