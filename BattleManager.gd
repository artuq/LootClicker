extends Node

var current_stage: int = 1
var player: PlayerStats
var current_enemy: Enemy
var player_timer: Timer
var enemy_timer: Timer

@export var damage_label_scene: PackedScene

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
	
	spawn_enemy()
	_start_combat()

func spawn_enemy():
	current_enemy = Enemy.new()
	add_child(current_enemy)
	
	var is_boss = (current_stage % 5 == 0)
	var hp = int(20 * pow(1.2, current_stage))
	var dmg = int(2 * pow(1.15, current_stage))
	var gold = int(5 * pow(1.1, current_stage))
	
	if is_boss:
		hp *= 4
		dmg *= 2
		gold *= 3
		enemy_sprite.modulate = Color.RED
		enemy_sprite.scale = Vector2(1.3, 1.3)
	else:
		enemy_sprite.modulate = Color.WHITE
		enemy_sprite.scale = Vector2(1.0, 1.0)
		
	current_enemy.setup_enemy(hp, dmg, gold, 10)
	current_enemy.died.connect(_on_enemy_died)
	
	stage_label.text = "Stage: %d / 20" % current_stage
	enemy_hp_bar.max_value = hp
	enemy_hp_bar.value = hp

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

