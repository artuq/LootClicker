extends Node
class_name GameBattleManager

var current_stage: int = 1
var player: PlayerStats
var current_enemy: Enemy
var player_timer: Timer
var enemy_timer: Timer

const SAVE_PASSWORD = "JoannaIndianaLootClicker2026"

@export var damage_label_scene: PackedScene
@export var upgrade_screen_scene: PackedScene # New export for level up UI
@export var skill_tree_scene: PackedScene # New export for full screen tree
@export var inventory_slot_scene: PackedScene 
@export var hit_particles_scene: PackedScene
@export var mummy_texture: Texture2D
@export var snake_texture: Texture2D
@export var boss_texture: Texture2D
@export var bar_green: Texture2D
@export var bar_yellow: Texture2D
@export var bar_red: Texture2D

# UI References
@onready var hp_label = %HPLabel
@onready var player_hp_bar = %PlayerHPBar
@onready var enemy_hp_label = %EnemyHPLabel
@onready var gold_label = %GoldLabel
@onready var stage_label = %StageLabel
@onready var next_level_btn = %NextLevelButton
@onready var xp_bar = %XPBar
@onready var click_area = %ClickArea
@onready var victory_ui = %VictoryUI

# Windows
@onready var inventory_window = %Inventory
@onready var inventory_grid = %InventoryGrid

# Graphics
@onready var enemy_sprite = %EnemySprite
@onready var enemy_hp_bar = %EnemyHPBar
@export var damage_container: Node # New export for damage labels

var shake_intensity: float = 0.0
var idle_tween: Tween 
var original_enemy_pos: Vector2

# Cached styles for dynamic HP bar colors
var style_green: StyleBoxTexture
var style_yellow: StyleBoxTexture
var style_red: StyleBoxTexture

# Constants for scaling and balance
const HP_BASE = 20
const HP_SCALE = 1.18 # Slightly lower scaling (was 1.2)
const DMG_BASE = 2
const DMG_SCALE = 1.12 # Slightly lower scaling (was 1.15)
const GOLD_BASE = 8    # More gold at start (was 5)
const GOLD_SCALE = 1.1
const BOSS_HP_MULT = 2.5 # Lowered boss HP (was 4)
const BOSS_DMG_MULT = 1.5 # Lowered boss DMG (was 2)
const BOSS_GOLD_MULT = 4  # More gold for boss kill

# Static variable to control game start from other scenes
static var startup_mode: String = "continue" # "continue" or "new_game"

func _ready():
	# Initialize styles
	style_green = StyleBoxTexture.new()
	style_green.texture = bar_green
	style_green.texture_margin_left = 6
	style_green.texture_margin_right = 6
	style_green.texture_margin_top = 6
	style_green.texture_margin_bottom = 6
	
	style_yellow = StyleBoxTexture.new()
	style_yellow.texture = bar_yellow
	style_yellow.texture_margin_left = 6
	style_yellow.texture_margin_right = 6
	style_yellow.texture_margin_top = 6
	style_yellow.texture_margin_bottom = 6
	
	style_red = StyleBoxTexture.new()
	style_red.texture = bar_red
	style_red.texture_margin_left = 6
	style_red.texture_margin_right = 6
	style_red.texture_margin_top = 6
	style_red.texture_margin_bottom = 6

	player = PlayerStats.new()
	add_child(player)
	
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()
	
	victory_ui.visible = false
	original_enemy_pos = enemy_sprite.position
	
	# UI Connections
	player.gold_changed.connect(func(g): 
		gold_label.text = format_number(g)
		_animate_label(gold_label)
	)
	player.health_changed.connect(func(c, m):	  
		hp_label.text = "HP: %s/%s" % [format_number(c), format_number(m)]
		player_hp_bar.max_value = m
		player_hp_bar.value = c
		_update_hp_bar_style(player_hp_bar)
		_animate_label(hp_label)
	)
		
	# XP Bar - Reordered to set max_value first
	var update_xp = func():
		if %XPLabel:
			%XPLabel.text = "XP: %d / %d" % [player.xp, player.xp_required]
		xp_bar.max_value = player.xp_required
		xp_bar.value = player.xp
		
	player.xp_changed.connect(update_xp)  # Update on every XP gain
	player.leveled_up.connect(func(_l): update_xp.call())
	update_xp.call()

	# Next Level Button Connection
	if not next_level_btn.pressed.is_connected(_on_next_level_button_pressed):
		next_level_btn.pressed.connect(_on_next_level_button_pressed)
	_add_button_juice(next_level_btn)
	_add_button_juice(%OpenTreeButton)
	
	if %SettingsHUD and not %SettingsHUD.pressed.is_connected(_on_settings_hud_pressed):
		%SettingsHUD.pressed.connect(_on_settings_hud_pressed)
	_add_button_juice(%SettingsHUD)
	
	# Timers
	player_timer = Timer.new()
	player_timer.timeout.connect(_on_player_attack)
	add_child(player_timer)
	
	enemy_timer = Timer.new()
	enemy_timer.wait_time = 1.5
	enemy_timer.timeout.connect(_on_enemy_attack)
	add_child(enemy_timer)
	
	player.leveled_up.connect(_on_player_leveled_up)
	player.consumables_updated.connect(_update_consumables_ui)
	player.resources_updated.connect(_update_inventory_ui)
	player.error_occurred.connect(func(msg): 
		_spawn_floating_text(msg, Color.ORANGE_RED)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_error_sound()
	)
	
	# START MODE SELECTION
	if startup_mode == "new_game":
		spawn_enemy()
	else:
		if not load_game():
			spawn_enemy()
	
	_update_consumables_ui()
	_update_inventory_ui()
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
	
	# Particles
	if hit_particles_scene:
		var p = hit_particles_scene.instantiate()
		add_child(p)
		p.global_position = enemy_sprite.global_position
		if is_crit:
			p.amount = 24
			p.color = Color.ORANGE
			p.scale_amount_max = 6.0
	
	# Hit Flash (Visual)
	var tween = create_tween()
	enemy_sprite.modulate = Color(10, 10, 10) # Overbright white
	tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)
	
	# Squash Effect - use current scale instead of fixed values
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
			"dodge_chance": player.dodge_chance,
			"block_chance": player.block_chance,
			"resources": player.resources,
			"consumables": player.consumables,
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
	player.dodge_chance = player_data.get("dodge_chance", 0.05)
	player.block_chance = player_data.get("block_chance", 0.0)
	player.resources = player_data.get("resources", player.resources)
	player.consumables = player_data.get("consumables", player.consumables)
	
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
	_update_consumables_ui()
	print("Game loaded from Slot %d!" % slot)
	return true


func format_number(n: int) -> String:
	if n >= 1_000_000:
		return "%.2fM" % (n / 1_000_000.0)
	elif n >= 1_000:
		return "%.1fk" % (n / 1_000.0)
	return str(n)

func _update_inventory_ui():
	if not inventory_grid: return
	
	# Clear existing
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# Display Resources
	var res_icons = {
		"bandages": "res://assets/icons/bandages_ai.png",       # AI-generated gray bandages icon
		"venom": "res://assets/icons/venom_ai.png",             # AI-generated green venom icon
		"relic_shards": "res://assets/icons/relic_shards_ai.png" # AI-generated purple relic shards icon
	}
	
	for res_id in player.resources.keys():
		var count = player.resources[res_id]
		if count > 0:
			var slot = inventory_slot_scene.instantiate()
			inventory_grid.add_child(slot)
			var tex = load(res_icons.get(res_id, "res://assets/sprites/icon.svg"))
			slot.set_item(tex, count, Color.MEDIUM_PURPLE)
			slot.tooltip_text = "%s: %d" % [res_id.capitalize(), count]
	
	# Display Equipment
	for item in player.inventory:
		var slot = inventory_slot_scene.instantiate()
		inventory_grid.add_child(slot)
		
		var icon_p = item.icon_path
		if icon_p == "": icon_p = "res://assets/icons/new_icons/Icons 512x512/24.png" # Default sword icon
		
		var tex = load(icon_p)
		var is_equipped = (item == player.equipped_item)
		var rarity_col = item.get_color()
		if is_equipped: rarity_col = Color.GOLD # Highlight equipped
		
		slot.set_item(tex, 1, rarity_col)
		var equip_text = "\n(EQUIPPED)" if is_equipped else ""
		slot.tooltip_text = "%s (+%d DMG)%s" % [item.name, item.damage_bonus, equip_text]

func _update_consumables_ui():
	var potion_btn = %PotionButton
	if potion_btn:
		var count = player.consumables.get("hp_potion", 0)
		potion_btn.text = "HP Pot: %d" % count
		potion_btn.disabled = count <= 0 or player.current_hp >= player.max_hp
		
		# Connect action if not already connected
		if not potion_btn.pressed.is_connected(_on_potion_button_pressed):
			potion_btn.pressed.connect(_on_potion_button_pressed)
			_add_button_juice(potion_btn)

func _add_button_juice(btn: Button):
	if not btn: return
	btn.pivot_offset = btn.size / 2
	
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_ui_hover_sound()
	)
	
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)
	
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.05)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_ui_click_sound()
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

func _on_potion_button_pressed():
	if player.use_consumable("hp_potion"):
		_spawn_floating_text("USED POTION +30", Color.SPRING_GREEN)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_coin_sound() # Temporary sound
		_update_consumables_ui()
	else:
		_spawn_floating_text("ALREADY FULL HP", Color.ORANGE)

func spawn_enemy(saved_hp: int = -1):
	if current_enemy:
		current_enemy.queue_free()
		
	current_enemy = Enemy.new()
	add_child(current_enemy)
	
	enemy_sprite.visible = true
	click_area.visible = true
	var is_boss = (current_stage % 5 == 0)
	var is_final_boss = (current_stage == 50)
	var hp = int(HP_BASE * pow(HP_SCALE, current_stage))
	var dmg = int(DMG_BASE * pow(DMG_SCALE, current_stage))
	var gold = int(GOLD_BASE * pow(GOLD_SCALE, current_stage))
	
	if is_final_boss:
		hp *= 10 # Massive scaling for final boss
		dmg *= 3
		gold *= 10
	elif is_boss:
		hp *= BOSS_HP_MULT
		dmg *= BOSS_DMG_MULT
		gold *= BOSS_GOLD_MULT
	
	var enemy_name = ""
	var res_type = ""
	
	if is_final_boss:
		enemy_sprite.texture = boss_texture
		enemy_name = "ULTIMATE BOSS: Saddam on the Raft"
		res_type = "relic_shards"
	elif is_boss:
		enemy_sprite.texture = boss_texture
		enemy_name = "BOSS: Raft Saddam"
		res_type = "relic_shards"
	else:
		if current_stage <= 10:
			enemy_sprite.texture = mummy_texture
			enemy_name = "Toilet Paper Mummy"
			res_type = "bandages"
		else:
			enemy_sprite.texture = snake_texture
			enemy_name = "Confused Snake"
			res_type = "venom"

	# --- AUTOMATIC SCALING ---
	print("DEBUG: SCALING ENEMY")
	var target_size = 200.0
	var tex_size = enemy_sprite.texture.get_size()
	var new_enemy_scale = target_size / max(tex_size.x, tex_size.y)
	enemy_sprite.scale = Vector2(new_enemy_scale, new_enemy_scale)
	print("DEBUG: Enemy texture set to %s, scale: %.2f" % [enemy_name, new_enemy_scale])
		
	enemy_sprite.position = Vector2(180, 240)
	original_enemy_pos = enemy_sprite.position
	
	_start_idle_animation()
		
	current_enemy.setup_enemy(hp, dmg, gold, 10 + current_stage, res_type)
	if saved_hp != -1:
		current_enemy.current_hp = saved_hp
		
	current_enemy.died.connect(_on_enemy_died)
	
	stage_label.text = "Stage: %d\n%s" % [current_stage, enemy_name]
	enemy_hp_bar.max_value = hp
	enemy_hp_bar.value = current_enemy.current_hp
	_update_hp_bar_style(enemy_hp_bar)
	enemy_hp_label.text = "%s / %s" % [format_number(current_enemy.current_hp), format_number(hp)]

func _on_click_area_pressed():
	_on_player_attack()

func _on_player_attack():
	if current_enemy:
		var dmg = player.get_total_damage()
		var is_crit = player.is_critical_hit()
		if is_crit: dmg *= 2
		
		var result = current_enemy.take_damage(dmg)
		
		if result == "MISS":
			_spawn_floating_text("MISS", Color.GRAY)
		else:
			enemy_hp_bar.value = current_enemy.current_hp
			_update_hp_bar_style(enemy_hp_bar)
			enemy_hp_label.text = "%s / %s" % [format_number(current_enemy.current_hp), format_number(enemy_hp_bar.max_value)]
			_spawn_floating_text(result + ("!!" if is_crit else ""), Color.YELLOW if not is_crit else Color.ORANGE)
			_play_hit_effect(is_crit)
			if get_node_or_null("/root/AudioManager"):
				get_node("/root/AudioManager").play_hit_sound(1.5 if is_crit else 1.0)

func _on_enemy_attack():
	if current_enemy and player.current_hp > 0:
		var result = player.take_damage(current_enemy.damage)
		
		if result == "DODGED":
			_spawn_floating_text("DODGED", Color.AQUA)
		else:
			var color = Color.WHITE if "BLOCKED" in result else Color(1, 0.2, 0.2)
			_spawn_floating_text(result, color)
			if player.current_hp <= 0: _handle_player_death()
			if get_node_or_null("/root/AudioManager"):
				get_node("/root/AudioManager").play_hit_sound(0.7)

func _on_enemy_died(_xp, gold, res_type = ""):
	player.gain_gold(gold)
	
	# XP Balance: Stage 1 guarantees level up (20 XP vs 20 req)
	var xp_reward = 20 if current_stage == 1 else 15 + (current_stage * 5)
	player.gain_xp(xp_reward) 
	
	# RESOURCE DROP
	if res_type != "":
		var res_chance = 0.6 # 60% chance
		if current_stage <= 3: res_chance = 1.0 # Higher drop at start
		if current_stage % 5 == 0: res_chance = 1.0
		
		if randf() < res_chance:
			player.add_resource(res_type, 1)
			_spawn_floating_text("+1 " + res_type.capitalize(), Color.MEDIUM_PURPLE)
			
	# POTION DROP (30% chance)
	if randf() < 0.3:
		player.consumables["hp_potion"] += 1
		_spawn_floating_text("LOOT: HP POTION", Color.GREEN_YELLOW)
		player.consumables_updated.emit()
	
	# Chance for immediate healing (15% chance)
	if randf() < 0.15:
		player.current_hp = min(player.max_hp, player.current_hp + 20)
		player.health_changed.emit(player.current_hp, player.max_hp)
		_spawn_floating_text("HEAL +20", Color.GREEN)
	
	xp_bar.max_value = player.xp_required
	xp_bar.value = player.xp
	
	enemy_sprite.visible = false
	click_area.visible = false
	if idle_tween: idle_tween.kill()
	
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()
		
	player_timer.stop()
	enemy_timer.stop()
	
	# SHOW VICTORY AND UPGRADE SCREEN
	victory_ui.visible = true

func _on_player_leveled_up(_new_level):
	_spawn_floating_text("LEVEL UP!", Color.GOLD)
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()
	
	# Instantiate card choice screen
	var card_scene = load("res://src/scenes/CardChoiceScene.tscn")
	if card_scene:
		var instance = card_scene.instantiate()
		%CanvasLayer.add_child(instance)
		instance.setup(player)

func _on_next_level_button_pressed():
	save_game()
	victory_ui.visible = false
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

func _handle_player_death():
	print("PLAYER DIED - GAME OVER")
	# Death penalty
	player.gold = int(player.gold * 0.8)
	current_stage = 1
	save_game()
	
	# Return to main menu
	var title_screen = load("res://src/scenes/TitleScreen.gd")
	if title_screen:
		title_screen.last_run_result = "DEFEAT"
	
	get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")

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

func _on_open_skill_tree():
	if !skill_tree_scene: return
	# Pause game while browsing skill tree
	get_tree().paused = true
	var tree = skill_tree_scene.instantiate()
	%CanvasLayer.add_child(tree)
	tree.setup(player)

func _on_settings_hud_pressed():
	get_tree().paused = true
	var settings = load("res://src/scenes/SettingsScene.tscn").instantiate()
	%CanvasLayer.add_child(settings)

func _animate_label(lbl: Control):
	var tween = create_tween()
	tween.tween_property(lbl, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.1)

func _update_hp_bar_style(bar: ProgressBar):
	var percent = (float(bar.value) / bar.max_value) * 100.0 if bar.max_value > 0 else 0.0
	
	if percent > 50:
		bar.add_theme_stylebox_override("fill", style_green)
	elif percent > 25:
		bar.add_theme_stylebox_override("fill", style_yellow)
	else:
		bar.add_theme_stylebox_override("fill", style_red)
