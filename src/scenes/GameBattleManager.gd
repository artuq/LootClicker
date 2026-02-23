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

# Enemy roster — loaded dynamically
var enemy_roster_jungle: Array[Dictionary] = []
var enemy_roster_temple: Array[Dictionary] = []
var boss_roster: Dictionary = {}   # stage -> boss data
@export var bar_yellow: Texture2D
@export var bar_red: Texture2D

# UI References
@onready var hp_label = %HPLabel
@onready var player_hp_bar = %PlayerHPBar
@onready var enemy_hp_label = %EnemyHPLabel
@onready var gold_label = %GoldLabel
@onready var stage_label = %StageLabel
@onready var next_level_btn = %NextLevelButton
@onready var click_area = %ClickArea
@onready var victory_ui = %VictoryUI

# Boss Progress UI
@onready var info_label = %InfoLabel
@onready var xp_label = %XPLabel
@onready var loot_summary_label = %LootSummaryLabel
@onready var dps_label = %DPSLabel

# Windows
@onready var inventory_window = %Inventory
@onready var inventory_grid = %InventoryGrid
@onready var combat_stats_label = %CombatStats
@onready var skill_stats_label = %SkillStats

# Graphics
@onready var enemy_sprite = %EnemySprite
@onready var enemy_hp_bar = %EnemyHPBar
@onready var biome_bg: TextureRect = get_node_or_null("../BackgroundLayer/JungleBG")
@export var damage_container: Node # New export for damage labels

# Biome backgrounds
var bg_jungle: Texture2D = preload("res://assets/sprites/Jungle.jpeg")
var bg_temple: Texture2D = preload("res://assets/sprites/Temple.jpeg")

var shake_intensity: float = 0.0
var idle_tween: Tween 
var original_enemy_pos: Vector2

# Action Bar & Shadow
var enemy_action_bar: ProgressBar
var enemy_shadow: Panel

# Near Death Experience (Vignette)
var vignette_overlay: ColorRect
var vignette_tween: Tween
var is_near_death: bool = false
const NEAR_DEATH_THRESHOLD = 0.2 # 20% HP

# Curse system
var poison_timer: Timer
var in_combat: bool = false

# Cached styles for dynamic HP bar colors
var style_green: StyleBoxTexture
var style_yellow: StyleBoxTexture
var style_red: StyleBoxTexture

# DPS tracking
var dps_damage_total: float = 0.0
var dps_timer: float = 0.0
var current_dps: float = 0.0

# Loot summary (per kill)
var kill_gold: int = 0
var kill_xp: int = 0
var kill_resource: String = ""
var kill_resource_amount: int = 0
var kill_potion: bool = false
var kill_item: GameItem = null # New item dropped this kill

# Tutorial
var tutorial_shown: bool = false

# Constants for scaling and balance
const HP_BASE = 20
const HP_SCALE = 1.18 # Slightly lower scaling (was 1.2)
const DMG_BASE = 2
const DMG_SCALE = 1.12 # Slightly lower scaling (was 1.15)
const GOLD_BASE = 12    # Buffed gold at start (was 8)
const GOLD_SCALE = 1.15 # Buffed scaling (was 1.1)
const BOSS_HP_MULT = 1.8 # Lowered boss HP (was 2.0)
const BOSS_DMG_MULT = 1.2 # Lowered boss DMG (was 1.3)
const BOSS_GOLD_MULT = 5  # More gold for boss kill (was 4)

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

	# Initialize enemy rosters
	_init_enemy_rosters()

	player = PlayerStats.new()
	add_child(player)
	
	_create_enemy_ui()
	_create_vignette_overlay()
	_init_admob()
	
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
		_update_consumables_ui() # Refresh potion button on HP change
		# Near Death Experience trigger
		var hp_ratio = float(c) / float(m) if m > 0 else 1.0
		_set_near_death(hp_ratio < NEAR_DEATH_THRESHOLD and c > 0)
	)
		
	# XP — update xp label on change
	var update_xp = func(_cur = 0, _req = 0):
		_update_xp_label()
		
	player.xp_changed.connect(update_xp)
	player.leveled_up.connect(func(_l): update_xp.call())
	update_xp.call()

	# Next Level Button Connection
	if not next_level_btn.pressed.is_connected(_on_next_level_button_pressed):
		next_level_btn.pressed.connect(_on_next_level_button_pressed)
	_add_button_juice(next_level_btn)
	_add_button_juice(%OpenTreeButton)
	
	# Watch Ad button
	var ad_btn = get_node_or_null("%WatchAdButton")
	if ad_btn:
		if not ad_btn.pressed.is_connected(_on_watch_ad_pressed):
			ad_btn.pressed.connect(_on_watch_ad_pressed)
		_add_button_juice(ad_btn)
	
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
	var loaded_between_fights = false
	if startup_mode == "new_game":
		spawn_enemy()
		# Show tutorial on first run
		call_deferred("_show_tutorial")
	else:
		var load_result = load_game()
		if load_result is Dictionary:
			loaded_between_fights = load_result.get("between_fights", false)
		elif not load_result:
			print("WARN: load_game failed, starting fresh")
			spawn_enemy()
			call_deferred("_show_tutorial")
	
	# Always force a full UI refresh after initialization
	call_deferred("_force_ui_refresh_after_load")
	
	_update_consumables_ui()
	_update_inventory_ui()
	_update_stats_ui()
	player.skills_updated.connect(_update_stats_ui)
	player.health_changed.connect(func(_c, _m): _update_stats_ui())
	player.gold_changed.connect(func(_g): _update_stats_ui())
	
	if loaded_between_fights:
		# Resume at victory screen — don't start combat
		in_combat = false
		enemy_sprite.visible = false
		click_area.visible = false
		victory_ui.visible = true
		_update_loot_summary()
	else:
		_start_combat()

# === Enemy Roster Data ===
func _init_enemy_rosters():
	enemy_roster_jungle = [
		{
			"name": "Angry Kaboom Squirrel",
			"texture": "res://assets/sprites/enemies/squirrel.png",
			"resource": "bandages",
		},
		{
			"name": "Intern Monkey",
			"texture": "res://assets/sprites/enemies/monkey.png",
			"resource": "bandages",
		},
		{
			"name": "Dieting Plant",
			"texture": "res://assets/sprites/enemies/plant.png",
			"resource": "venom",
		},
		{
			"name": "Toilet Paper Mummy",
			"texture": "res://assets/sprites/Mumia-removebg-preview.png",
			"resource": "bandages",
		},
		{
			"name": "Confused Snake",
			"texture": "res://assets/sprites/Snake-removebg-preview.png",
			"resource": "venom",
		},
	]
	enemy_roster_temple = [
		{
			"name": "Tourist Skeleton",
			"texture": "res://assets/sprites/enemies/skeleton.png",
			"resource": "venom",
		},
		{
			"name": "Budget Golem",
			"texture": "res://assets/sprites/enemies/golem.png",
			"resource": "relic_shards",
		},
		{
			"name": "Sheet Ghost",
			"texture": "res://assets/sprites/enemies/ghost.png",
			"resource": "venom",
		},
		{
			"name": "Toilet Paper Mummy",
			"texture": "res://assets/sprites/Mumia-removebg-preview.png",
			"resource": "bandages",
		},
		{
			"name": "Confused Snake",
			"texture": "res://assets/sprites/Snake-removebg-preview.png",
			"resource": "venom",
		},
	]
	boss_roster = {
		10: {
			"name": "The Allergic Idol",
			"texture": "res://assets/sprites/enemies/boss_idol.png",
			"resource": "relic_shards",
			"greeting": "Ah... Ah... CHOO!",
			"scale": 280.0,
		},
		25: {
			"name": "Brad the Influencer",
			"texture": "res://assets/sprites/enemies/boss_brad.png",
			"resource": "relic_shards",
			"greeting": "Don't forget to like and subscribe!",
			"scale": 260.0,
		},
		40: {
			"name": "The Budget Sphinx",
			"texture": "res://assets/sprites/enemies/boss_sphinx.png",
			"resource": "relic_shards",
			"greeting": "Meow. Give me gold.",
			"scale": 280.0,
		},
	}

func _update_biome_bg():
	"""Switch background texture based on current stage biome."""
	if not biome_bg:
		return
	if current_stage <= 14:
		biome_bg.texture = bg_jungle
	elif current_stage <= 20:
		# Transition zone — use temple
		biome_bg.texture = bg_temple
	elif current_stage <= 40:
		biome_bg.texture = bg_temple
	else:
		# Stage 41+: mixed — use temple
		biome_bg.texture = bg_temple

func _get_enemy_for_stage(stage: int) -> Dictionary:
	"""Returns a random enemy dict based on biome rules."""
	var roll = randf()
	if stage <= 14:
		# Pure jungle
		return enemy_roster_jungle.pick_random()
	elif stage <= 20:
		# 80% jungle / 20% temple
		if roll < 0.8:
			return enemy_roster_jungle.pick_random()
		else:
			return enemy_roster_temple.pick_random()
	elif stage <= 35:
		# Pure temple
		return enemy_roster_temple.pick_random()
	elif stage <= 40:
		# 80% temple / 20% jungle
		if roll < 0.8:
			return enemy_roster_temple.pick_random()
		else:
			return enemy_roster_jungle.pick_random()
	else:
		# Stage 41+: mixed
		if roll < 0.5:
			return enemy_roster_jungle.pick_random()
		else:
			return enemy_roster_temple.pick_random()

func _process(delta):
	if shake_intensity > 0:
		enemy_sprite.position = original_enemy_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0, delta * 50.0)
	else:
		enemy_sprite.position = original_enemy_pos
		
	# Action Bar UI Update
	if in_combat and enemy_action_bar and enemy_timer and not enemy_timer.is_stopped():
		var progress = 1.0 - (enemy_timer.time_left / enemy_timer.wait_time)
		enemy_action_bar.value = progress * 100.0

	# DPS tracking
	if in_combat:
		dps_timer += delta
		if dps_timer >= 1.0:
			current_dps = dps_damage_total / dps_timer
			if dps_label:
				dps_label.text = "DPS: %s" % format_number(int(current_dps))
			dps_damage_total = 0.0
			dps_timer = 0.0

func _start_idle_animation():
	if idle_tween: idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var base_scale = enemy_sprite.scale
	idle_tween.tween_property(enemy_sprite, "scale", base_scale * 1.05, 1.2).set_trans(Tween.TRANS_SINE)
	idle_tween.tween_property(enemy_sprite, "scale", base_scale, 1.2).set_trans(Tween.TRANS_SINE)

func _vibrate(duration_ms: int = 50):
	if OS.has_feature("android") or OS.has_feature("ios"):
		Input.vibrate_handheld(duration_ms)

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
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		# Mid-combat: save with full HP enemy so player restarts the stage
		if in_combat and current_enemy:
			var orig_hp = current_enemy.current_hp
			current_enemy.current_hp = int(HP_BASE * pow(HP_SCALE, current_stage))
			if boss_roster.has(current_stage):
				current_enemy.current_hp *= BOSS_HP_MULT
			elif current_stage % 5 == 0:
				current_enemy.current_hp *= BOSS_HP_MULT
			elif current_stage == 50:
				current_enemy.current_hp *= 10
			save_game()
			current_enemy.current_hp = orig_hp  # Restore in case app resumes
		else:
			save_game()

func save_game(slot: int = 1):
	var save_data = {
		"current_stage": current_stage,
		"enemy_hp": current_enemy.current_hp if current_enemy else -1,
		"enemy_name": current_enemy.enemy_name if current_enemy else "",
		"between_fights": not in_combat,
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
			"card_str": player.card_str,
			"card_crit": player.card_crit,
			"card_speed": player.card_speed,
			"card_greed": player.card_greed,
			"card_def": player.card_def,
			"card_hp": player.card_hp,
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
	var saved_enemy_name = data.get("enemy_name", "")
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
	player.card_str = player_data.get("card_str", 0)
	player.card_crit = player_data.get("card_crit", 0)
	player.card_speed = player_data.get("card_speed", 0)
	player.card_greed = player_data.get("card_greed", 0)
	player.card_def = player_data.get("card_def", 0)
	player.card_hp = player_data.get("card_hp", 0)
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

	var between = data.get("between_fights", false)
	if not between:
		spawn_enemy(saved_enemy_hp, saved_enemy_name)
	else:
		# Between fights: spawn next stage enemy (ready for Next Level)
		spawn_enemy(-1, saved_enemy_name)
	# Force full UI refresh after load
	call_deferred("_force_ui_refresh_after_load")
	print("Game loaded from Slot %d!" % slot)
	return {"success": true, "between_fights": between}


func _force_ui_refresh_after_load():
	# Deferred to ensure all @onready nodes are fully ready
	hp_label.text = "HP: %s/%s" % [format_number(player.current_hp), format_number(player.max_hp)]
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.current_hp
	_update_hp_bar_style(player_hp_bar)
	gold_label.text = format_number(player.gold)
	player.health_changed.emit(player.current_hp, player.max_hp)
	player.gold_changed.emit(player.gold)
	player.skills_updated.emit()
	_update_inventory_ui()
	_update_consumables_ui()
	_update_stats_ui()
	_update_xp_label()

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
		"bandages": "res://assets/icons/bandage.png",
		"venom": "res://assets/icons/venom.png",
		"relic_shards": "res://assets/icons/crystal.png",
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

func _update_stats_ui():
	if not combat_stats_label or not skill_stats_label or not player: return
	var dmg = player.get_total_damage()
	var spd = player.get_attack_speed()
	var total_crit = player.crit_lvl + player.card_crit
	var total_def = player.def_lvl + player.card_def
	var total_greed = player.greed_lvl + player.card_greed
	var crit_ch = min(80.0, total_crit * 1.0)
	var crit_m = player.get_crit_multiplier()
	var def_red = min(50.0, total_def * 2.0)
	var gold_b = total_greed * 5
	var dodge = player.dodge_chance * 100.0
	var block = player.block_chance * 100.0

	# Left column — Combat
	var cl := ""
	cl += "[b]Combat[/b]\n"
	cl += "DMG: %d\n" % dmg
	cl += "SPD: %.2fs\n" % spd
	cl += "Crit: %.0f%%\n" % crit_ch
	cl += "Crit DMG: x%.2f\n" % crit_m
	cl += "DEF: -%.0f%%\n" % def_red
	cl += "Gold: +%d%%\n" % gold_b
	cl += "Dodge: %.0f%%\n" % dodge
	cl += "Block: %.0f%%" % block
	combat_stats_label.text = cl

	# Right column — Skills (tree + card) + Curses
	var sr := ""
	sr += "[b]Skills (Tree+Card)[/b]\n"
	sr += "STR: %d+%d\n" % [player.str_lvl, player.card_str]
	sr += "HP: %d+%d\n" % [int((player.max_hp - 100 - player.card_hp * 20) / 20.0), player.card_hp]
	sr += "Greed: %d+%d\n" % [player.greed_lvl, player.card_greed]
	sr += "Crit: %d+%d\n" % [player.crit_lvl, player.card_crit]
	sr += "Speed: %d+%d\n" % [player.speed_lvl, player.card_speed]
	sr += "Def: %d+%d\n" % [player.def_lvl, player.card_def]
	if player.active_curses.size() > 0:
		sr += "[b]Curses[/b]\n"
		for c in player.active_curses:
			var cname = c.get("id", "?").replace("curse_", "").capitalize()
			sr += "[color=red]%s[/color] (%d)\n" % [cname, c.get("stages", 0)]
	skill_stats_label.text = sr

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

func _add_button_juice(btn: BaseButton):
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
		var heal_amount = max(30, int(player.max_hp * 0.3))
		_spawn_floating_text("POTION +%d" % heal_amount, Color.SPRING_GREEN)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_coin_sound() # Temporary sound
		_update_consumables_ui()
	else:
		_spawn_floating_text("ALREADY FULL HP", Color.ORANGE)

func _find_enemy_by_name(search_name: String) -> Dictionary:
	"""Look up enemy data by name across all rosters."""
	for e in enemy_roster_jungle:
		if e.name == search_name:
			return e
	for e in enemy_roster_temple:
		if e.name == search_name:
			return e
	return {}

func spawn_enemy(saved_hp: int = -1, saved_name: String = ""):
	if current_enemy:
		current_enemy.queue_free()
		
	current_enemy = Enemy.new()
	add_child(current_enemy)
	
	enemy_sprite.visible = true
	click_area.visible = true
	
	var is_named_boss = boss_roster.has(current_stage)
	var is_mini_boss = (current_stage % 5 == 0) and not is_named_boss
	var is_final_boss = (current_stage == 50)
	
	# SOFT LANDING SCALING: Exponential up to 30, Linear after 30
	var hp: int = 0
	var dmg: int = 0
	
	if current_stage <= 30:
		# Existing exponential logic with Stage 25 nerf
		var eff_hp_scale = HP_SCALE
		var eff_dmg_scale = DMG_SCALE
		if current_stage > 25:
			eff_hp_scale = 1.0 + (HP_SCALE - 1.0) * 0.85
			eff_dmg_scale = 1.0 + (DMG_SCALE - 1.0) * 0.8
		
		hp = int(HP_BASE * pow(eff_hp_scale, current_stage))
		dmg = int(DMG_BASE * pow(eff_dmg_scale, current_stage))
	else:
		# Linear logic: calculate peak at 30 and add constant increment
		var hp_30 = int(HP_BASE * pow(1.0 + (HP_SCALE - 1.0) * 0.85, 30))
		var dmg_30 = int(DMG_BASE * pow(1.0 + (DMG_SCALE - 1.0) * 0.8, 30))
		
		# Increments: heavily reduced to prevent massive endgame spikes
		var hp_inc = int(hp_30 * 0.06) 
		var dmg_inc = int(dmg_30 * 0.05)
		
		hp = hp_30 + (current_stage - 30) * hp_inc
		dmg = dmg_30 + (current_stage - 30) * dmg_inc
	
	var gold = int(GOLD_BASE * pow(GOLD_SCALE, current_stage))
	
	var enemy_name = ""
	var res_type = ""
	# Uniform enemy sizes: normal 160, elite 180, boss 200, final 220
	var target_size = 160.0
	
	if is_final_boss:
		hp = int(hp * 2.5)
		dmg = int(dmg * 1.4)
		gold *= 10
		enemy_sprite.texture = boss_texture
		enemy_name = "ULTIMATE BOSS: Saddam on the Raft"
		res_type = "relic_shards"
		target_size = 220.0
	elif is_named_boss:
		hp *= BOSS_HP_MULT
		dmg *= BOSS_DMG_MULT
		gold *= BOSS_GOLD_MULT
		var boss_data = boss_roster[current_stage]
		enemy_sprite.texture = load(boss_data.texture)
		enemy_name = "BOSS: %s" % boss_data.name
		res_type = boss_data.resource
		target_size = 200.0
		# Show boss greeting
		_show_boss_greeting(boss_data.greeting)
	elif is_mini_boss:
		hp *= BOSS_HP_MULT
		dmg *= BOSS_DMG_MULT
		gold *= BOSS_GOLD_MULT
		# Restore saved enemy or pick random
		var base_name = saved_name.replace("ELITE: ", "") if saved_name.begins_with("ELITE: ") else saved_name
		var enemy_data = _find_enemy_by_name(base_name) if base_name != "" else {}
		if enemy_data.is_empty():
			enemy_data = _get_enemy_for_stage(current_stage)
		enemy_sprite.texture = load(enemy_data.texture)
		enemy_name = "ELITE: %s" % enemy_data.name
		res_type = enemy_data.resource
		target_size = 180.0
	else:
		# Restore saved enemy or pick random
		var enemy_data = _find_enemy_by_name(saved_name) if saved_name != "" else {}
		if enemy_data.is_empty():
			enemy_data = _get_enemy_for_stage(current_stage)
		enemy_sprite.texture = load(enemy_data.texture)
		enemy_name = enemy_data.name
		res_type = enemy_data.resource

	# --- AUTOMATIC SCALING ---
	var tex_size = enemy_sprite.texture.get_size()
	var new_enemy_scale = target_size / max(tex_size.x, tex_size.y)
	enemy_sprite.scale = Vector2(new_enemy_scale, new_enemy_scale)
	print("DEBUG: Enemy texture set to %s, scale: %.2f" % [enemy_name, new_enemy_scale])
		
	enemy_sprite.position = Vector2(180, 240)
	original_enemy_pos = enemy_sprite.position
	
	# Switch biome background based on stage
	_update_biome_bg()
	
	_start_idle_animation()
		
	current_enemy.setup_enemy(hp, dmg, gold, 10 + current_stage, res_type)
	current_enemy.enemy_name = enemy_name
	if saved_hp != -1:
		current_enemy.current_hp = saved_hp
		
	current_enemy.died.connect(_on_enemy_died)
	
	stage_label.text = "Stage %d — %s" % [current_stage, enemy_name]
	_update_info_label()
	enemy_hp_bar.max_value = hp
	enemy_hp_bar.value = current_enemy.current_hp
	_update_hp_bar_style(enemy_hp_bar)
	enemy_hp_label.text = "%s / %s" % [format_number(current_enemy.current_hp), format_number(hp)]

# Adrenaline mechanic
var adrenaline_clicks: int = 0
const ADRENALINE_THRESHOLD: int = 50
const ADRENALINE_DURATION: float = 5.0
var adrenaline_timer_left: float = 0.0
var adrenaline_active: bool = false

func _on_click_area_pressed():
	_on_player_attack()
	
	# Adrenaline build up
	if not adrenaline_active:
		adrenaline_clicks += 1
		if adrenaline_clicks >= ADRENALINE_THRESHOLD:
			_activate_adrenaline()
			
	# Blood Price curse: HP cost per click (only during combat)
	if in_combat and player.click_hp_cost > 0:
		player.on_click_curse_cost()
		if player.current_hp <= 0:
			_handle_player_death()

func _activate_adrenaline():
	adrenaline_active = true
	adrenaline_clicks = 0
	adrenaline_timer_left = ADRENALINE_DURATION
	_spawn_floating_text("ADRENALINE!!! x2 DMG", Color.GOLDENROD)
	_vibrate(150)
	
	# Visual pulsing label
	var ad_label = Label.new()
	%CanvasLayer.add_child(ad_label)
	ad_label.text = "ADRENALINE ACTIVE!"
	ad_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ad_label.add_theme_font_size_override("font_size", 20)
	ad_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	ad_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	ad_label.position.y = 100
	
	# Fix scaling pivot (assuming standard 360 width, center is 180)
	ad_label.pivot_offset = Vector2(180, 15)
	
	var tween = create_tween().set_loops()
	tween.tween_property(ad_label, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(ad_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Timer to stop
	await get_tree().create_timer(ADRENALINE_DURATION).timeout
	adrenaline_active = false
	adrenaline_clicks = 0
	tween.kill()
	ad_label.queue_free()
	_spawn_floating_text("Adrenaline ended", Color.GRAY)

func _on_player_attack():
	if current_enemy:
		var dmg = player.get_total_damage()
		
		# Apply Adrenaline buff
		if adrenaline_active:
			dmg *= 2
			
		var is_crit = player.is_critical_hit()
		if is_crit: dmg = int(dmg * player.get_crit_multiplier())
		
		# Track DPS
		dps_damage_total += dmg
		
		var result = current_enemy.take_damage(dmg)
		
		if result == "MISS":
			_spawn_floating_text("MISS", Color.GRAY)
		else:
			enemy_hp_bar.value = current_enemy.current_hp
			_update_hp_bar_style(enemy_hp_bar)
			enemy_hp_label.text = "%s / %s" % [format_number(current_enemy.current_hp), format_number(enemy_hp_bar.max_value)]
			_spawn_floating_text(result + ("!!" if is_crit else ""), Color.YELLOW if not is_crit else Color.ORANGE)
			_play_hit_effect(is_crit)
			# Vibration feedback on hit
			_vibrate(30 if not is_crit else 60)
			# Thorns: reflect damage to player
			if player.thorns_percent > 0 and current_enemy:
				var reflect_dmg = int(dmg * player.thorns_percent)
				if reflect_dmg > 0:
					player.current_hp = max(1, player.current_hp - reflect_dmg)
					player.health_changed.emit(player.current_hp, player.max_hp)
					_spawn_floating_text("THORNS -%d" % reflect_dmg, Color.DARK_RED)
			if get_node_or_null("/root/AudioManager"):
				get_node("/root/AudioManager").play_hit_sound(1.5 if is_crit else 1.0)

func _on_enemy_attack():
	if current_enemy and player.current_hp > 0:
		var result = player.take_damage(current_enemy.damage)
		
		# Enemy White Flash & Lunge
		var base_scale = enemy_sprite.scale
		var flash_tween = create_tween()
		enemy_sprite.modulate = Color(10, 10, 10) # White flash
		enemy_sprite.scale = base_scale * 1.1
		enemy_sprite.position.y += 20 # Small lunge forward
		flash_tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.15)
		flash_tween.parallel().tween_property(enemy_sprite, "scale", base_scale, 0.15)
		flash_tween.parallel().tween_property(enemy_sprite, "position:y", original_enemy_pos.y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		if result == "DODGED":
			_spawn_floating_text("DODGED", Color.AQUA)
		else:
			var color = Color.WHITE if "BLOCKED" in result else Color(1, 0.2, 0.2)
			_spawn_floating_text(result, color)
			
			# Screen Flash on hit
			if not "BLOCKED" in result:
				var screen_flash = ColorRect.new()
				screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
				screen_flash.color = Color(1, 0.8, 0.8, 0.3) # Slight reddish white
				screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
				var flash_layer = CanvasLayer.new()
				flash_layer.layer = 105
				add_child(flash_layer)
				flash_layer.add_child(screen_flash)
				var out_tween = create_tween()
				out_tween.tween_property(screen_flash, "color:a", 0.0, 0.1)
				out_tween.tween_callback(flash_layer.queue_free)
				
			if player.current_hp <= 0: _handle_player_death()
			if get_node_or_null("/root/AudioManager"):
				get_node("/root/AudioManager").play_hit_sound(0.7)

func _create_enemy_ui():
	# Create Shadow (an elliptical dark panel)
	enemy_shadow = Panel.new()
	var shadow_style = StyleBoxFlat.new()
	shadow_style.bg_color = Color(0, 0, 0, 0.35)
	shadow_style.corner_radius_top_left = 60
	shadow_style.corner_radius_top_right = 60
	shadow_style.corner_radius_bottom_left = 60
	shadow_style.corner_radius_bottom_right = 60
	enemy_shadow.add_theme_stylebox_override("panel", shadow_style)
	enemy_shadow.custom_minimum_size = Vector2(140, 20)
	enemy_shadow.position = original_enemy_pos + Vector2(-70, 110)
	%CanvasLayer.add_child(enemy_shadow)
	
	if %EnemySprite:
		%CanvasLayer.move_child(enemy_shadow, %EnemySprite.get_index())

	# Create Action Bar
	enemy_action_bar = ProgressBar.new()
	enemy_action_bar.custom_minimum_size = Vector2(120, 10)
	enemy_action_bar.show_percentage = false
	enemy_action_bar.value = 0.0
	
	# Style the action bar (Orange to look distinct from Red HP)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	
	var fg_style = StyleBoxFlat.new()
	fg_style.bg_color = Color(1.0, 0.6, 0.1, 1.0) # Vibrant Orange
	fg_style.corner_radius_top_left = 4
	fg_style.corner_radius_top_right = 4
	fg_style.corner_radius_bottom_left = 4
	fg_style.corner_radius_bottom_right = 4
	
	enemy_action_bar.add_theme_stylebox_override("background", bg_style)
	enemy_action_bar.add_theme_stylebox_override("fill", fg_style)
	enemy_action_bar.position = original_enemy_pos + Vector2(-60, 140)
	%CanvasLayer.add_child(enemy_action_bar)

func _on_enemy_died(_xp, gold, res_type = ""):
	# Vibrate on kill
	_vibrate(100)
	# Reset loot summary for this kill
	kill_gold = gold
	kill_xp = 0
	kill_resource = ""
	kill_resource_amount = 0
	kill_potion = false
	kill_item = null
	
	player.gain_gold(gold)
	
	# XP Balance: Stage 1 guarantees level up (20 XP vs 20 req)
	var xp_reward = 20 if current_stage == 1 else 15 + (current_stage * 5)
	kill_xp = xp_reward
	player.gain_xp(xp_reward) 
	
	# RESOURCE DROP (guaranteed, amounts scale with stage)
	if res_type != "":
		var drop_amount = 1
		if current_stage >= 5:
			drop_amount = randi_range(1, 2)
		if current_stage >= 15:
			drop_amount = randi_range(2, 3)
		if current_stage >= 30:
			drop_amount = randi_range(2, 4)
		# Bosses & elites drop extra
		if current_stage % 5 == 0:
			drop_amount += randi_range(1, 2)
		player.add_resource(res_type, drop_amount)
		kill_resource = res_type
		kill_resource_amount = drop_amount
		_spawn_floating_text("+%d %s" % [drop_amount, res_type.capitalize()], Color.MEDIUM_PURPLE)
			
	# POTION DROP (40% chance)
	if randf() < 0.4:
		player.consumables["hp_potion"] += 1
		kill_potion = true
		_spawn_floating_text("LOOT: HP POTION", Color.GREEN_YELLOW)
		player.consumables_updated.emit()
	
	# Force clean inventory from unauthorized "junk" items
	player.inventory.clear()
	player.equipped_item = null
	
	_update_info_label()
	
	enemy_sprite.visible = false
	click_area.visible = false
	if idle_tween: idle_tween.kill()
	
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()
		
	player_timer.stop()
	enemy_timer.stop()
	in_combat = false
	# Stop curse effects between stages
	if poison_timer and not poison_timer.is_stopped():
		poison_timer.stop()
	
	# Auto-save after every kill
	save_game()
	
	# Reset ad counter for this stage & update ad button
	ad_uses_this_stage = 0
	var ad_btn = get_node_or_null("%WatchAdButton")
	if ad_btn:
		ad_btn.disabled = player.current_hp >= player.max_hp
		ad_btn.text = "FULL HEAL (Ad)"
	
	# SHOW VICTORY AND UPGRADE SCREEN
	_update_loot_summary()
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
	# Tick down stage-based curses
	player.on_stage_advance()
	if player.active_curses.size() > 0:
		var names = player.get_active_curse_names()
		_spawn_floating_text("Curses: %s" % ", ".join(names), Color.DARK_RED)
	spawn_enemy()
	_start_combat()

func _start_combat():
	in_combat = true
	dps_damage_total = 0.0
	dps_timer = 0.0
	current_dps = 0.0
	if dps_label:
		dps_label.text = ""
	player_timer.wait_time = player.get_attack_speed()
	player_timer.start()
	enemy_timer.start()
	# Start poison timer if player has poison curse
	_update_poison_timer()

func _on_skills_updated():
	if player_timer:
		player_timer.wait_time = player.get_attack_speed()
		if not player_timer.is_stopped(): player_timer.start()

func _handle_player_death():
	print("PLAYER DIED - GAME OVER")
	_vibrate(300)  # Strong vibration on death
	# Reset near-death effects before scene change
	_set_near_death(false)
	# Don't save — last auto-save checkpoint (after previous kill) is preserved
	# Player chooses Continue (reload checkpoint) or New Game from title screen
	
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
	settings.setup()

# === WATCH AD FOR FULL HEAL ===
var ad_uses_this_stage: int = 0
const MAX_AD_PER_STAGE: int = 1
const DEBUG_FORCE_FAKE_ADS: bool = true # ALWAYS TRUE for now

# AdMob Rewarded Ad
var _rewarded_ad: RewardedAd = null
var _admob_available: bool = false
const REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

func _init_admob():
	if DEBUG_FORCE_FAKE_ADS:
		print("[AdMob] Mode: FAKE ADS ENABLED")
		_admob_available = false
		return
		
	print("[AdMob] OS.get_name() = %s" % OS.get_name())
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		var request_config := RequestConfiguration.new()
		request_config.test_device_ids = ["AF60FD39718814D8E7ABDCB44DC92518"]
		MobileAds.set_request_configuration(request_config)
		
		var listener = OnInitializationCompleteListener.new()
		listener.on_initialization_complete = func(status: InitializationStatus):
			_admob_available = true
			await get_tree().create_timer(1.0).timeout
			_preload_rewarded_ad()
		MobileAds.initialize(listener)

func _preload_rewarded_ad():
	if not _admob_available or DEBUG_FORCE_FAKE_ADS: return
	var callback = RewardedAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: RewardedAd): _rewarded_ad = ad
	callback.on_ad_failed_to_load = func(_err): _rewarded_ad = null
	RewardedAdLoader.new().load(REWARDED_AD_UNIT_ID, AdRequest.new(), callback)

func _on_watch_ad_pressed():
	if ad_uses_this_stage >= MAX_AD_PER_STAGE:
		_spawn_floating_text("AD LIMIT REACHED", Color.ORANGE)
		return
	if player.current_hp >= player.max_hp:
		_spawn_floating_text("ALREADY FULL HP", Color.ORANGE)
		return
	
	if not DEBUG_FORCE_FAKE_ADS and _admob_available and _rewarded_ad:
		_show_real_ad()
	else:
		_show_fake_ad()

func _grant_ad_reward():
	player.current_hp = player.max_hp
	player.health_changed.emit(player.current_hp, player.max_hp)
	ad_uses_this_stage += 1
	_spawn_floating_text("FULL HEAL!", Color.SPRING_GREEN)
	_vibrate(60)
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()
	_update_consumables_ui()
	save_game()
	if %WatchAdButton:
		%WatchAdButton.disabled = true
		%WatchAdButton.text = "AD USED"

func _show_real_ad():
	var reward_listener = OnUserEarnedRewardListener.new()
	reward_listener.on_user_earned_reward = func(_reward): _grant_ad_reward()
	_rewarded_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func():
		_rewarded_ad = null
		_preload_rewarded_ad()
	_rewarded_ad.show(reward_listener)

func _show_fake_ad():
	var backdrop = ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.95)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	%CanvasLayer.add_child(backdrop)
	
	var center = VBoxContainer.new()
	# Crucial fix: Make it grow symmetrically from its anchor point
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 20)
	backdrop.add_child(center)
	
	var title = Label.new()
	title.text = "FAKE AD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color.GOLD)
	center.add_child(title)
	
	var progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(250, 24)
	progress.max_value = 5.0
	progress.value = 0.0
	progress.show_percentage = false
	center.add_child(progress)
	
	var status = Label.new()
	status.text = "Reward in 5s..."
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(status)
	
	# Use Tween for the 5s timer - more reliable than Timer node
	var ad_tween = create_tween()
	# Update progress bar
	ad_tween.tween_property(progress, "value", 5.0, 5.0)
	
	# Periodic status update
	var timer_loop = 5
	for i in range(5):
		ad_tween.parallel().tween_callback(func(): status.text = "Reward in %ds..." % (5-i)).set_delay(float(i))
	
	# Final cleanup and reward
	ad_tween.tween_callback(func():
		_grant_ad_reward()
		var out_t = create_tween()
		out_t.tween_property(backdrop, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		out_t.tween_callback(backdrop.queue_free)
	)

func _animate_label(lbl: Control):
	var tween = create_tween()
	tween.tween_property(lbl, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(lbl, "scale", Vector2(1.0, 1.0), 0.1)

# === Near Death Experience (Vignette + Audio) ===

# === Boss Greeting ===
func _show_boss_greeting(text: String):
	var greeting_layer = CanvasLayer.new()
	greeting_layer.layer = 90
	add_child(greeting_layer)
	
	# Dark overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate = Color(1, 1, 1, 0)
	greeting_layer.add_child(overlay)
	
	# Greeting label
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.GOLD)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.position = Vector2(-150, -20)
	lbl.size = Vector2(300, 40)
	lbl.modulate = Color(1, 1, 1, 0)
	greeting_layer.add_child(lbl)
	
	# Animate in → hold → out
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(lbl, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tween.tween_callback(greeting_layer.queue_free)

func _create_vignette_overlay():
	vignette_overlay = ColorRect.new()
	vignette_overlay.name = "VignetteOverlay"
	# Full-screen overlay
	vignette_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette_overlay.modulate = Color(1, 1, 1, 0) # Start invisible
	
	# Vignette shader: red edges, transparent center
	var shader = Shader.new()
	shader.code = """
		shader_type canvas_item;
		uniform float intensity : hint_range(0.0, 1.0) = 0.7;
		uniform vec4 vignette_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			float dist = length(uv) * 2.0;
			float vignette = smoothstep(0.3, 1.2, dist) * intensity;
			COLOR = vec4(vignette_color.rgb, vignette);
		}
	"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	vignette_overlay.material = mat
	
	# Add to a high CanvasLayer so it's on top of everything
	var vignette_layer = CanvasLayer.new()
	vignette_layer.name = "VignetteLayer"
	vignette_layer.layer = 100
	add_child(vignette_layer)
	vignette_layer.add_child(vignette_overlay)

func _set_near_death(enabled: bool):
	if enabled == is_near_death:
		return
	is_near_death = enabled
	
	if vignette_tween:
		vignette_tween.kill()
	
	if enabled:
		# Fade in vignette
		vignette_tween = create_tween()
		vignette_tween.tween_property(vignette_overlay, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
		vignette_tween.tween_callback(_start_vignette_pulse)
		# Audio: low-pass + heartbeat
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").set_near_death_audio(true)
	else:
		# Fade out vignette
		vignette_tween = create_tween()
		vignette_tween.tween_property(vignette_overlay, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
		# Audio: restore
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").set_near_death_audio(false)

func _start_vignette_pulse():
	if not is_near_death:
		return
	if vignette_tween:
		vignette_tween.kill()
	vignette_tween = create_tween().set_loops()
	vignette_tween.tween_property(vignette_overlay, "modulate:a", 0.4, 0.6).set_trans(Tween.TRANS_SINE)
	vignette_tween.tween_property(vignette_overlay, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

func _update_hp_bar_style(bar: ProgressBar):
	var percent = (float(bar.value) / bar.max_value) * 100.0 if bar.max_value > 0 else 0.0
	
	if percent > 50:
		bar.add_theme_stylebox_override("fill", style_green)
	elif percent > 25:
		bar.add_theme_stylebox_override("fill", style_yellow)
	else:
		bar.add_theme_stylebox_override("fill", style_red)

# === Curse System: Poison Timer ===
func _update_poison_timer():
	if player.poison_dps > 0:
		if not poison_timer:
			poison_timer = Timer.new()
			poison_timer.wait_time = 1.0
			poison_timer.timeout.connect(_on_poison_tick)
			add_child(poison_timer)
		if poison_timer.is_stopped():
			poison_timer.start()
	else:
		if poison_timer and not poison_timer.is_stopped():
			poison_timer.stop()

func _on_poison_tick():
	if not in_combat:
		return
	if player.poison_dps > 0 and player.current_hp > 0:
		player.apply_poison_tick()
		_spawn_floating_text("POISON -%d" % player.poison_dps, Color.PURPLE)
		if player.current_hp <= 1:
			_spawn_floating_text("DANGER!", Color.RED)

# === MVP POLISH: Unified Info Label ===
func _get_next_boss_stage(from_stage: int) -> int:
	var boss_stages = boss_roster.keys()
	boss_stages.sort()
	for bs in boss_stages:
		if bs > from_stage:
			return bs
	if from_stage < 50:
		return 50
	return -1

func _get_biome_name(stage: int) -> String:
	if stage <= 14:
		return "Jungle"
	elif stage <= 20:
		return "Jungle/Temple"
	elif stage <= 35:
		return "Temple"
	elif stage <= 40:
		return "Temple/Jungle"
	else:
		return "Endless"

func _update_info_label():
	if not info_label:
		return
	var biome = _get_biome_name(current_stage)
	var boss_text = ""
	var next_boss = _get_next_boss_stage(current_stage - 1)
	if next_boss == -1:
		boss_text = "Free roam"
	else:
		var prev_boss = 0
		var boss_stages = boss_roster.keys()
		boss_stages.sort()
		for bs in boss_stages:
			if bs < current_stage:
				prev_boss = bs
		var total = next_boss - prev_boss
		var done = current_stage - prev_boss
		if current_stage == next_boss:
			boss_text = "BOSS!"
		else:
			var bname = ""
			if boss_roster.has(next_boss):
				bname = boss_roster[next_boss].name
			elif next_boss == 50:
				bname = "Final Boss"
			boss_text = "%d/%d %s" % [done, total, bname]
	info_label.text = "%s  %s" % [biome, boss_text]

func _update_xp_label():
	if not xp_label:
		return
	xp_label.text = "XP %d / %d" % [player.xp, player.xp_required]

# === MVP POLISH: Loot Summary ===
func _update_loot_summary():
	if not loot_summary_label:
		return
	var parts: Array[String] = []
	parts.append("%s gold" % format_number(kill_gold))
	parts.append("%d XP" % kill_xp)
	if kill_resource != "" and kill_resource_amount > 0:
		parts.append("+%d %s" % [kill_resource_amount, kill_resource.capitalize()])
	if kill_potion:
		parts.append("+Potion")
	if kill_item:
		parts.append("+%s (%s)" % [kill_item.name, kill_item.rarity])
	loot_summary_label.text = " · ".join(parts)
	# Animate
	loot_summary_label.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(loot_summary_label, "modulate:a", 1.0, 0.3)

# === MVP POLISH: First-Run Tutorial ===
func _show_tutorial():
	if tutorial_shown:
		return
	tutorial_shown = true
	
	var tut_layer = CanvasLayer.new()
	tut_layer.layer = 95
	add_child(tut_layer)
	
	# Semi-transparent backdrop
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.75)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	tut_layer.add_child(backdrop)
	
	# Tutorial panel
	var panel = VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-140, -120)
	panel.size = Vector2(280, 240)
	tut_layer.add_child(panel)
	
	var title_lbl = Label.new()
	var sys_font = SystemFont.new()
	sys_font.font_names = PackedStringArray(["sans-serif", "Segoe UI Emoji", "Apple Color Emoji", "Noto Color Emoji"])
	title_lbl.text = "⚔ Welcome, adventurer!"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", sys_font)
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color.GOLD)
	panel.add_child(title_lbl)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	panel.add_child(spacer)
	
	var tips = [
		"👆 TAP the enemy to attack",
		"⏱ You also attack automatically",
		"💀 Defeat enemies → earn gold & XP",
		"⬆ Level up → choose upgrade cards",
		"🏛 Every 5 stages → elite enemy",
		"👑 Every 10 stages → BOSS fight!",
	]
	
	for tip in tips:
		var lbl = Label.new()
		lbl.text = tip
		lbl.add_theme_font_override("font", sys_font)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(lbl)
	
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 15)
	panel.add_child(spacer2)
	
	var btn = Button.new()
	btn.text = "Let's GO!"
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(200, 40)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_child(btn)
	
	# Fade in via backdrop (CanvasLayer has no modulate)
	backdrop.modulate = Color(1, 1, 1, 0)
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.4)
	
	btn.pressed.connect(func():
		var out_tween = create_tween()
		out_tween.tween_property(backdrop, "modulate:a", 0.0, 0.3)
		out_tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.3)
		out_tween.tween_callback(tut_layer.queue_free)
	)
