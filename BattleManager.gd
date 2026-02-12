extends Node

var player: PlayerStats
var current_enemy: Enemy
var attack_timer: Timer

@export var damage_label_scene: PackedScene

# --- REFERENCJE UI (Dopasowane IDEALNIE do Twojego obrazka) ---
@onready var hp_label = $"../CanvasLayer/HPLabel"
@onready var gold_label = $"../CanvasLayer/GoldLabel"
@onready var inventory_button = $"../CanvasLayer/InventoryButton"
@onready var inventory_window = $"../CanvasLayer/InventoryWindow"
@onready var item_list = $"../CanvasLayer/InventoryWindow/ItemList"
@onready var enemy_hp_bar = $"../CanvasLayer/EnemyHPBar"
@onready var enemy_sprite = $"../CanvasLayer/EnemySprite"

func _ready():
	# Inicjalizacja gracza
	player = PlayerStats.new()
	add_child(player)
	
	# Łączenie sygnałów - to one aktualizują napisy
	player.gold_changed.connect(_update_gold_ui)
	player.health_changed.connect(_update_hp_ui)
	
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	item_list.item_activated.connect(_on_item_activated)
	
	inventory_window.visible = false
	
	# WYMUSZENIE pierwszej aktualizacji, żeby napisy nie były puste
	_update_gold_ui(player.gold)
	_update_hp_ui(player.current_hp, player.max_hp)
	
	# Timer ataku
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0
	attack_timer.autostart = true
	attack_timer.timeout.connect(_on_attack_timer_tick)
	add_child(attack_timer)
	
	spawn_enemy()

func spawn_enemy():
	current_enemy = Enemy.new()
	add_child(current_enemy)
	current_enemy.setup_enemy("Angry Cat", 20, 15, 5)
	current_enemy.died.connect(_on_enemy_died)
	
	enemy_hp_bar.max_value = current_enemy.max_hp
	enemy_hp_bar.value = current_enemy.current_hp

func _on_attack_timer_tick():
	if current_enemy != null:
		var dmg = player.get_total_damage()
		current_enemy.take_damage(dmg)
		enemy_hp_bar.value = current_enemy.current_hp 
		spawn_damage_number(dmg)
		shake_enemy()
	else:
		spawn_enemy()

func shake_enemy():
	var tween = create_tween()
	var original_pos = enemy_sprite.position
	tween.tween_property(enemy_sprite, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(enemy_sprite, "position", original_pos - Vector2(10, 0), 0.05)
	tween.tween_property(enemy_sprite, "position", original_pos, 0.05)

func spawn_damage_number(amount: int):
	if damage_label_scene == null: return
	var dmg_label = damage_label_scene.instantiate()
	dmg_label.text = str(amount)
	$"../CanvasLayer".add_child(dmg_label)
	
	dmg_label.global_position = enemy_sprite.global_position
	dmg_label.global_position.x -= dmg_label.size.x / 2
	dmg_label.global_position.y -= 60

func _on_enemy_died(xp, gold):
	player.gain_xp(xp)
	player.gain_gold(gold)
	_roll_for_loot()
	spawn_enemy()

func _update_gold_ui(new_amount):
	gold_label.text = "Gold: " + str(new_amount)

func _update_hp_ui(current, max_hp):
	# Ten kod sprawi, że napis "Player HP" się pojawi
	hp_label.text = "Player HP: " + str(current) + " / " + str(max_hp)

func _roll_for_loot():
	if randf() <= 0.5:
		var new_item = GameItem.new()
		new_item.item_name = "Rusty Sword"
		new_item.damage_bonus = randi_range(2, 5)
		player.add_item_to_inventory(new_item)

func _on_inventory_button_pressed():
	inventory_window.visible = !inventory_window.visible
	if inventory_window.visible: _refresh_inventory_list()

func _refresh_inventory_list():
	item_list.clear()
	if player.inventory.size() == 0:
		item_list.add_item("Backpack is empty...")
	else:
		for item in player.inventory:
			var text = item.get_description()
			if player.equipped_weapon == item: text = "[E] " + text
			item_list.add_item(text)

func _on_item_activated(index):
	player.equipped_weapon = player.inventory[index]
	_refresh_inventory_list()
