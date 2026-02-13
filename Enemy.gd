extends Node
class_name Enemy

signal died(xp, gold)

var max_hp: int
var current_hp: int
var damage: int
var gold_reward: int
var xp_reward: int

# NAPRAWA: Funkcja przyjmuje teraz 4 argumenty, tak jak wymaga tego BattleManager
func setup_enemy(hp: int, dmg: int, gold: int, xp: int):
	max_hp = hp
	current_hp = hp
	damage = dmg
	gold_reward = gold
	xp_reward = xp

func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		died.emit(xp_reward, gold_reward)
		queue_free()
