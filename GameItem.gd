extends Resource
class_name GameItem

@export var name: String = "Item"
@export var damage_bonus: int = 1
@export var rarity: String = "Common"

const RARITY_COLORS = {
	"Common": Color.WHITE,
	"Rare": Color.CYAN,
	"Epic": Color.PURPLE,
	"Legendary": Color.ORANGE
}

func _init(p_name = "Item", p_dmg = 1, p_rarity = "Common"):
	name = p_name
	damage_bonus = p_dmg
	rarity = p_rarity

func get_color() -> Color:
	return RARITY_COLORS.get(rarity, Color.WHITE)
