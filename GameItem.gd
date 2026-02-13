extends Resource
class_name GameItem

@export var name: String = "Item"
@export var damage_bonus: int = 1

func _init(p_name = "Item", p_dmg = 1):
	name = p_name
	damage_bonus = p_dmg
