extends Node

var current_stage: int = 1
var player: PlayerStats
var current_enemy: Enemy
var player_timer: Timer
var enemy_timer: Timer

@export var damage_label_scene: PackedScene
@export var mummy_texture: Texture2D
@export var snake_texture: Texture2D
@export var boss_texture: Texture2D

# UI References
@onready var hp_label = $"../CanvasLayer/HPLabel"
@onready var gold_label = $"../CanvasLayer/GoldLabel"
@onready var stage_label = $"../CanvasLayer/StageLabel"
@onready var next_level_btn = $"../CanvasLayer/NextLevelButton"

# Okna
@onready var skill_tree_window = $"../CanvasLayer/SkillTreeWindow"
@onready var inventory_window = $"../CanvasLayer/InventoryWindow"
@onready var inventory_button = $"../CanvasLayer/InventoryButton"
@onready var skill_button = $"../CanvasLayer/SkillButton"

# Grafika
@onready var enemy_sprite = $"../CanvasLayer/EnemySprite"
@onready var enemy_hp_bar = $"../CanvasLayer/EnemyHPBar"

func _ready():
	player = PlayerStats.new()
	add_child(player)
	
	next_level_btn.visible = false
	
	# Połączenia UI
	player.gold_changed.connect(func(g): gold_label.text = "Gold: " + str(g))
	player.health_changed.connect(func(c, m): hp_label.text = "HP: %d/%d" % [c, m])
	player.item_added.connect(func(item): _spawn_floating_text("LOOT: " + item.name, Color.CYAN))

	# Obsługa okien
	inventory_button.pressed.connect(func(): 
		inventory_window.visible = !inventory_window.visible
		if inventory_window.visible: skill_tree_window.visible = false
	)
	
	skill_button.pressed.connect(func(): 
		skill_tree_window.visible = !skill_tree_window.visible
		if skill_tree_window.visible: inventory_window.visible = false
		if skill_tree_window.visible: skill_tree_window.update_ui()
	)
	
	# --- NAPRAWA BŁĘDU Z OBRAZKA (Signal already connected) ---
	if not next_level_btn.pressed.is_connected(_on_next_level_button_pressed):
		next_level_btn.pressed.connect(_on_next_level_button_pressed)
	
	if skill_tree_window:
		skill_tree_window.setup(player)
		skill_tree_window.visible = false

	# Timery
	player_timer = Timer.new()
	player_timer.timeout.connect(_on_player_attack)
	add_child(player_timer)
	
	enemy_timer = Timer.new()
	enemy_timer.wait_time = 1.5
	enemy_timer.timeout.connect(_on_enemy_attack)
	add_child(enemy_timer)
	
	player.skills_updated.connect(_on_skills_updated)
	
	# Load game AFTER connecting UI signals
	if not load_game():
		spawn_enemy()
	
	_start_combat()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func save_game(slot: int = 1):
	var save_data = {
		"current_stage": current_stage,
		"enemy_hp": current_enemy.current_hp if current_enemy else -1,
		"player": {
			"max_hp": player.max_hp,
			"current_hp": player.current_hp,
			"gold": player.gold,
			"str_lvl": player.str_lvl,
			"crit_lvl": player.crit_lvl,
			"greed_lvl": player.greed_lvl,
			"speed_lvl": player.speed_lvl,
			"def_lvl": player.def_lvl,
			"heal_count": player.heal_count,
			"inventory": []
		}
	}
	for item in player.inventory:
		save_data["player"]["inventory"].append({
			"name": item.name,
			"damage_bonus": item.damage_bonus
		})
	
	var path = "user://savegame_slot%d.json" % slot
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Game saved to Slot %d!" % slot)

func load_game(slot: int = 1):
	var path = "user://savegame_slot%d.json" % slot
	if not FileAccess.file_exists(path):
		print("No save found in Slot %d" % slot)
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	current_stage = data["current_stage"]
	var saved_enemy_hp = data.get("enemy_hp", -1)
	
	var player_data = data["player"]
	player.max_hp = player_data["max_hp"]
	player.current_hp = player_data["current_hp"]
	player.gold = player_data["gold"]
	player.str_lvl = player_data["str_lvl"]
	player.crit_lvl = player_data["crit_lvl"]
	player.greed_lvl = player_data["greed_lvl"]
	player.speed_lvl = player_data["speed_lvl"]
	player.def_lvl = player_data["def_lvl"]
	player.heal_count = player_data.get("heal_count", 0)
	
	print("Loaded Slot %d: Stage %d, HP %d/%d, Gold %d" % [slot, current_stage, player.current_hp, player.max_hp, player.gold])
	
	player.inventory.clear()
	player.equipped_item = null
	
	for item_data in player_data["inventory"]:
		var new_item = GameItem.new(item_data["name"], item_data["damage_bonus"])
		player.inventory.append(new_item)
		if player.equipped_item == null or new_item.damage_bonus > player.equipped_item.damage_bonus:
			player.equipped_item = new_item

	spawn_enemy(saved_enemy_hp)
	player.health_changed.emit(player.current_hp, player.max_hp)
	player.gold_changed.emit(player.gold)
	player.skills_updated.emit()
	print("Game loaded from Slot %d!" % slot)
	return true


func spawn_enemy(saved_hp: int = -1):
	if current_enemy:
		current_enemy.queue_free()
		
	current_enemy = Enemy.new()
	add_child(current_enemy)
	
	var is_boss = (current_stage % 5 == 0)
	var hp = int(20 * pow(1.2, current_stage))
	var dmg = int(2 * pow(1.15, current_stage))
	var gold = int(5 * pow(1.1, current_stage))
	
	var enemy_name = ""
	if is_boss:
		hp *= 4
		dmg *= 2
		gold *= 3
		enemy_sprite.texture = boss_texture
		enemy_sprite.modulate = Color.WHITE # No red modulate needed if using boss texture
		enemy_sprite.scale = Vector2(0.5, 0.5) # Adjusting scale for potentially large JPEG
		enemy_name = "BOSS: Raft Saddam"
	else:
		if current_stage <= 10:
			enemy_sprite.texture = mummy_texture
			enemy_name = "Toilet Paper Mummy"
		else:
			enemy_sprite.texture = snake_texture
			enemy_name = "Confused Snake"
		
		enemy_sprite.modulate = Color.WHITE
		enemy_sprite.scale = Vector2(0.3, 0.3) # Adjusting scale for JPEGs
		
	current_enemy.setup_enemy(hp, dmg, gold, 10)
	if saved_hp != -1:
		current_enemy.current_hp = saved_hp
		
	current_enemy.died.connect(_on_enemy_died)
	
	stage_label.text = "Stage: %d / 20\n%s" % [current_stage, enemy_name]
	enemy_hp_bar.max_value = hp
	enemy_hp_bar.value = current_enemy.current_hp

func _on_player_attack():
	if current_enemy:
		var dmg = player.get_total_damage()
		if player.is_critical_hit(): dmg *= 2
		current_enemy.take_damage(dmg)
		enemy_hp_bar.value = current_enemy.current_hp
		_spawn_floating_text(str(dmg), Color.YELLOW)

func _on_enemy_attack():
	if current_enemy and player.current_hp > 0:
		var dmg = current_enemy.damage
		player.take_damage(dmg)
		_spawn_floating_text(str(dmg), Color(1, 0.2, 0.2)) # Czerwony
		if player.current_hp <= 0: _handle_player_death()

func _on_enemy_died(_xp, gold):
	player.gain_gold(gold)
	_roll_for_loot()
	player_timer.stop()
	enemy_timer.stop()
	next_level_btn.visible = true

func _roll_for_loot():
	if randf() < 0.3: # 30% szansy na loot
		var dmg_bonus = current_stage + randi() % 3
		var new_item = GameItem.new("Sword +" + str(dmg_bonus), dmg_bonus)
		player.add_item(new_item)

func _on_next_level_button_pressed():
	save_game()
	next_level_btn.visible = false
	current_stage += 1
	spawn_enemy()
	_start_combat()

func _start_combat():
	player_timer.wait_time = player.get_attack_speed()
	player_timer.start()
	enemy_timer.start()

func _on_skills_updated():
	if player_timer:
		player_timer.wait_time = player.get_attack_speed()
		if not player_timer.is_stopped(): player_timer.start()

# NOTE: The 'BtnDef' signal is connected to this script instead of SkillTree.gd.
# While this works, for better organization, consider connecting signals 
# to the node that directly handles the logic (in this case, SkillTree.gd).
func _on_btn_def_pressed():
	if skill_tree_window:
		skill_tree_window._buy("def")

func _handle_player_death():
	player.current_hp = player.max_hp
	player.health_changed.emit(player.current_hp, player.max_hp)
	spawn_enemy()
	_start_combat()

func _spawn_floating_text(text: String, color: Color):
	if !damage_label_scene: return
	var lbl = damage_label_scene.instantiate()
	lbl.text = text
	lbl.modulate = color
	$"../CanvasLayer".add_child(lbl)
	
	if text.begins_with("LOOT"):
		lbl.global_position = enemy_sprite.global_position + Vector2(0, -100)
		lbl.scale = Vector2(1.5, 1.5)
	elif color == Color.YELLOW:
		lbl.global_position = enemy_sprite.global_position + Vector2(randf_range(-20, 20), -50)
	else:
		lbl.global_position = hp_label.global_position + Vector2(40, 40)

func _on_save_slot_pressed(slot: int):
	save_game(slot)

func _on_load_slot_pressed(slot: int):
	load_game(slot)
