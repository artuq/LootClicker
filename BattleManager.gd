extends Node

var current_stage: int = 1
var player: PlayerStats
var current_enemy: Enemy
var player_timer: Timer
var enemy_timer: Timer

const SAVE_PASSWORD = "JoannaIndianaLootClicker2026"

@export var damage_label_scene: PackedScene
@export var mummy_texture: Texture2D
@export var snake_texture: Texture2D
@export var boss_texture: Texture2D

# UI References
@onready var hp_label = %HPLabel
@onready var gold_label = %GoldLabel
@onready var stage_label = %StageLabel
@onready var next_level_btn = %NextLevelButton

# Okna
@onready var skill_tree_window = %Upgrades
@onready var inventory_window = %Inventory

# Grafika
@onready var enemy_sprite = %EnemySprite
@onready var enemy_hp_bar = %EnemyHPBar
@export var damage_container: Node # New export for damage labels

var shake_intensity: float = 0.0
var idle_tween: Tween 
@onready var original_enemy_pos: Vector2 = enemy_sprite.position

# Constants for scaling and balance
const HP_BASE = 20
const HP_SCALE = 1.2
const DMG_BASE = 2
const DMG_SCALE = 1.15
const GOLD_BASE = 5
const GOLD_SCALE = 1.1
const BOSS_HP_MULT = 4
const BOSS_DMG_MULT = 2
const BOSS_GOLD_MULT = 3

func _ready():
	player = PlayerStats.new()
	add_child(player)
	
	next_level_btn.visible = false
	
	# Połączenia UI
	player.gold_changed.connect(func(g): gold_label.text = "Gold: " + format_number(g))
	player.health_changed.connect(func(c, m): hp_label.text = "HP: %s/%s" % [format_number(c), format_number(m)])
	player.item_added.connect(func(item): _spawn_floating_text("LOOT: " + item.name, Color.CYAN))

	# --- NAPRAWA BŁĘDU Z OBRAZKA (Signal already connected) ---
	if not next_level_btn.pressed.is_connected(_on_next_level_button_pressed):
		next_level_btn.pressed.connect(_on_next_level_button_pressed)
	
	if skill_tree_window:
		skill_tree_window.setup(player)

	# Timery
	player_timer = Timer.new()
	player_timer.timeout.connect(_on_player_attack)
	add_child(player_timer)
	
	enemy_timer = Timer.new()
	enemy_timer.wait_time = 1.5
	enemy_timer.timeout.connect(_on_enemy_attack)
	add_child(enemy_timer)
	
	player.skills_updated.connect(_on_skills_updated)
	player.error_occurred.connect(func(msg): 
		_spawn_floating_text(msg, Color.ORANGE_RED)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_error_sound()
	)
	
	# Load game AFTER connecting UI signals
	if not load_game():
		spawn_enemy()
	
	_start_combat()

func _process(delta):
	if shake_intensity > 0:
		enemy_sprite.position = original_enemy_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0, delta * 50.0)
	else:
		enemy_sprite.position = original_enemy_pos

func _start_idle_animation():
	if idle_tween: idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var base_scale = enemy_sprite.scale
	idle_tween.tween_property(enemy_sprite, "scale", base_scale * 1.05, 1.2).set_trans(Tween.TRANS_SINE)
	idle_tween.tween_property(enemy_sprite, "scale", base_scale, 1.2).set_trans(Tween.TRANS_SINE)

func _play_hit_effect(is_crit: bool):
	shake_intensity = 15.0 if is_crit else 5.0
	
	# Hit Flash (Visual)
	var tween = create_tween()
	enemy_sprite.modulate = Color(10, 10, 10) # Overbright white
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)
	
	# Squash Effect - używamy aktualnej skali zamiast stałych
	var base_scale = enemy_sprite.scale
	var hit_tween = create_tween()
	enemy_sprite.scale = base_scale * 0.8
	hit_tween.tween_property(enemy_sprite, "scale", base_scale, 0.2).set_trans(Tween.TRANS_ELASTIC)

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
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SAVE_PASSWORD)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved (encrypted) to Slot %d!" % slot)

func load_game(slot: int = 1):
	var path = "user://savegame_slot%d.json" % slot
	if not FileAccess.file_exists(path):
		print("No save found in Slot %d" % slot)
		return false
	
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SAVE_PASSWORD)
	if not file:
		print("Error opening encrypted save file in Slot %d" % slot)
		return false
		
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data == null:
		print("Failed to parse save data in Slot %d (wrong password or corrupted)" % slot)
		return false
	
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
	_update_inventory_ui()
	print("Game loaded from Slot %d!" % slot)
	return true


func format_number(n: int) -> String:
	if n >= 1_000_000:
		return "%.2fM" % (n / 1_000_000.0)
	elif n >= 1_000:
		return "%.1fk" % (n / 1_000.0)
	return str(n)

func spawn_enemy(saved_hp: int = -1):
	if current_enemy:
		current_enemy.queue_free()
		
	current_enemy = Enemy.new()
	add_child(current_enemy)
	
	var is_boss = (current_stage % 5 == 0)
	var hp = int(HP_BASE * pow(HP_SCALE, current_stage))
	var dmg = int(DMG_BASE * pow(DMG_SCALE, current_stage))
	var gold = int(GOLD_BASE * pow(GOLD_SCALE, current_stage))
	
	var enemy_name = ""
	
	# Dobieramy teksturę
	if is_boss:
		enemy_sprite.texture = boss_texture
		enemy_name = "BOSS: Raft Saddam"
		enemy_hp_bar.modulate = Color(1, 0.3, 0.3)
	else:
		if current_stage <= 10:
			enemy_sprite.texture = mummy_texture
			enemy_name = "Toilet Paper Mummy"
		else:
			enemy_sprite.texture = snake_texture
			enemy_name = "Confused Snake"
		enemy_hp_bar.modulate = Color.WHITE

	# --- AUTOMATYCZNE SKALOWANIE (Dostosowane do 360x640) ---
	enemy_sprite.modulate = Color.WHITE
	var tex_w = enemy_sprite.texture.get_width()
	
	# ZŁOTY ŚRODEK: Mob zajmuje połowę ekranu (180px), Boss trochę więcej (240px)
	var target_width = 240.0 if is_boss else 180.0
	var final_scale = target_width / tex_w
	
	enemy_sprite.scale = Vector2(final_scale, final_scale)
		
	# Pozycjonujemy przeciwnika w centrum pola walki (Y=240)
	enemy_sprite.position = Vector2(180, 240)
	original_enemy_pos = enemy_sprite.position
	
	# RESETUJEMY ANIMACJĘ ODDECHU (by nie nadpisywała nowej skali)
	_start_idle_animation()
		
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
		var is_crit = player.is_critical_hit()
		if is_crit: dmg *= 2
		current_enemy.take_damage(dmg)
		enemy_hp_bar.value = current_enemy.current_hp
		_spawn_floating_text(format_number(dmg), Color.YELLOW)
		
		# Visual effects
		_play_hit_effect(is_crit)
		
		# Audio: Wyższy ton przy krytyku
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_hit_sound(1.5 if is_crit else 1.0)

func _on_enemy_attack():
	if current_enemy and player.current_hp > 0:
		var dmg = current_enemy.damage
		player.take_damage(dmg)
		_spawn_floating_text(format_number(dmg), Color(1, 0.2, 0.2)) # Czerwony
		if player.current_hp <= 0: _handle_player_death()
		
		# Audio: Niższy ton uderzenia przeciwnika
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_hit_sound(0.7)

func _on_enemy_died(_xp, gold):
	player.gain_gold(gold)
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()
	_roll_for_loot()
	player_timer.stop()
	enemy_timer.stop()
	next_level_btn.visible = true

func _roll_for_loot():
	if randf() < 0.3: # 30% szansy na loot
		var dmg_bonus = current_stage + randi() % 3
		var new_item = GameItem.new("Sword +" + str(dmg_bonus), dmg_bonus)
		player.add_item(new_item)
		_update_inventory_ui()

func _update_inventory_ui():
	var list = %ItemList
	if list:
		list.clear()
		for item in player.inventory:
			list.add_item("%s (Dmg: +%d)" % [item.name, item.damage_bonus])

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
	
	if damage_container:
		damage_container.add_child(lbl)
	else:
		add_child(lbl) # Fallback to current node
	
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
