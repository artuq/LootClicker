extends Node
class_name Enemy

signal died(xp, gold, resource_type)

var max_hp: int
var current_hp: int
var damage: int
var gold_reward: int
var xp_reward: int
var enemy_resource: String = ""

# FIX: Function now takes 5 arguments for resources
func setup_enemy(hp: int, dmg: int, gold: int, xp: int, res_type: String = ""):
	max_hp = hp
	current_hp = hp
	damage = dmg
	gold_reward = gold
	xp_reward = xp
	enemy_resource = res_type

func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		died.emit(xp_reward, gold_reward, enemy_resource)
		queue_free()
