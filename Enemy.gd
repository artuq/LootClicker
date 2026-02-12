extends Node
class_name Enemy

# Sygnał wysyłany do BattleManagera, gdy wróg zginie
signal died(xp, gold)

# Statystyki przeciwnika
var enemy_name: String = "Enemy"
var max_hp: int = 20
var current_hp: int = 20
var xp_reward: int = 10
var gold_reward: int = 5

# Funkcja ustawiająca statystyki (wywoływana przy spawnowaniu)
func setup_enemy(nname: String, hp: int, xp: int, ggold: int):
	enemy_name = nname
	max_hp = hp
	current_hp = hp
	xp_reward = xp
	gold_reward = ggold

# Funkcja otrzymywania obrażeń
func take_damage(amount: int):
	current_hp -= amount
	print(enemy_name, " took ", amount, " damage. HP left: ", current_hp)
	
	if current_hp <= 0:
		die()

# Funkcja obsługująca śmierć
func die():
	print(enemy_name, " died!")
	# Wysyłamy informację o nagrodzie do BattleManagera
	died.emit(xp_reward, gold_reward)
	# Usuwamy wroga ze świata gry
	queue_free()
