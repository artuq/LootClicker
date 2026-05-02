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
@onready var enemy_hp_label = %EnemyFloatName
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
@onready var combat_stats_panel: PanelContainer = %CombatStats
@onready var skill_stats_panel: PanelContainer = %SkillStats
@onready var bottom_panel: Panel = get_node_or_null("../BottomNavLayer/BottomPanel")
@onready var bottom_content_area: MarginContainer = get_node_or_null("../BottomNavLayer/BottomPanel/BottomLayout/ContentArea")
@onready var bottom_tab_container: TabContainer = get_node_or_null("../BottomNavLayer/BottomPanel/BottomLayout/ContentArea/TabContainer")
@onready var nav_inventory_btn: Button = %InventoryTabBtn
@onready var nav_stats_btn: Button = %StatsTabBtn

# New UI nodes (ISSUE-12)
@onready var xp_bar = %XPBar
@onready var enemy_nameplate_label = %EnemyFloatName
@onready var loot_icons_grid = %LootIconsGrid

# Graphics
@onready var enemy_sprite = %EnemySprite
@onready var enemy_hp_bar = %EnemyFloatHPBar
@onready var enemy_attack_bar = %EnemyFloatAttackBar
@onready var jungle_base_bg: TextureRect = get_node_or_null("../BackgroundLayer/JungleBaseBG")
@onready var temple_bg: TextureRect = get_node_or_null("../BackgroundLayer/TempleBG")
@export var damage_container: Node # New export for damage labels

# Managers (Phase 1 refactor)
var vfx: Node
var notif: Node
var enemy_hud: Node
var bottom_nav: Node
var stats_renderer: Node
var tut: Node  # TutorialManager

# Biome backgrounds
var bg_jungle: Texture2D = preload("res://assets/sprites/Jungle.jpeg")
var bg_temple: Texture2D = preload("res://assets/sprites/Temple.jpeg")

# Enemy floating HUD timer bar
var enemy_action_bar: ProgressBar # 20% HP

# Curse system
var poison_timer: Timer
var in_combat: bool = false


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
var reward_popup_node: Control = null
var level_up_sequence_pending: bool = false
var victory_popup_pending_after_reward: bool = false
var victory_ui_tween: Tween = null
var _next_stage_label: Label = null
var _selected_inventory_slot: InventorySlot = null
var _item_desc_panel: PanelContainer = null
var _item_desc_label: RichTextLabel = null

const UI_STATE_COMBAT = 0
const UI_STATE_VICTORY = 1
const UI_STATE_REWARD = 2
var ui_state: int = UI_STATE_COMBAT

const POTION_ICON_PATH = "res://assets/kenney_tiny-dungeon/Tiles/tile_0115.png"
const POTION_ICON_TEXTURE: Texture2D = preload("res://assets/kenney_tiny-dungeon/Tiles/tile_0115.png")
var resource_icon_paths: Dictionary = {
	"bandages": "res://assets/icons/bandage.png",
	"venom": "res://assets/icons/venom.png",
	"relic_shards": "res://assets/icons/crystal.png",
}
var icon_texture_cache: Dictionary = {}

# Tutorial texture (passed to TutorialManager)
const TUTORIAL_HAND_TEXTURE: Texture2D = preload("res://assets/ui/tutorial/hand_cursor.png")

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
	_fix_parallax_sizes()

	# Fade in from black — prevents TitleScreen overlay bleedthrough during scene transition
	var _intro_layer := CanvasLayer.new()
	_intro_layer.layer = 200
	add_child(_intro_layer)
	var _intro_rect := ColorRect.new()
	_intro_rect.color = Color.BLACK
	_intro_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_intro_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_layer.add_child(_intro_rect)
	var _intro_t := create_tween()
	_intro_t.tween_property(_intro_rect, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	_intro_t.tween_callback(_intro_layer.queue_free)

	# Allow TitleScreen to pass startup mode without relying on script statics.
	if get_tree().has_meta("startup_mode"):
		startup_mode = str(get_tree().get_meta("startup_mode"))
		get_tree().remove_meta("startup_mode")

	# Initialize enemy rosters
	_init_enemy_rosters()

	player = PlayerStats.new()
	add_child(player)

	# --- Initialize managers (Phase 1 refactor) ---
	vfx = load("res://src/scripts/VFXManager.gd").new()
	vfx.name = "VFXManager"
	add_child(vfx)
	vfx.setup({
		"enemy_sprite": enemy_sprite,
		"damage_label_scene": damage_label_scene,
		"damage_container": damage_container,
		"hp_label": hp_label,
		"hit_particles_scene": hit_particles_scene,
		"canvas_layer": %CanvasLayer,
	})

	enemy_hud = load("res://src/scripts/EnemyHUD.gd").new()
	enemy_hud.name = "EnemyHUD"
	add_child(enemy_hud)
	enemy_hud.setup({
		"enemy_hp_bar": enemy_hp_bar,
		"enemy_nameplate_label": enemy_nameplate_label,
		"enemy_attack_bar": enemy_attack_bar,
		"bar_green": bar_green,
		"bar_yellow": bar_yellow,
		"bar_red": bar_red,
	})
	enemy_action_bar = enemy_attack_bar

	notif = load("res://src/scripts/NotificationManager.gd").new()
	notif.name = "NotificationManager"
	add_child(notif)
	notif.setup({
		"info_label": info_label,
		"canvas_layer": %CanvasLayer,
	})

	bottom_nav = load("res://src/scripts/BottomNavManager.gd").new()
	bottom_nav.name = "BottomNavManager"
	add_child(bottom_nav)
	bottom_nav.setup({
		"owner": self,
		"bottom_panel": bottom_panel,
		"bottom_content_area": bottom_content_area,
		"bottom_tab_container": bottom_tab_container,
		"nav_inventory_btn": nav_inventory_btn,
		"nav_stats_btn": nav_stats_btn,
	})

	stats_renderer = load("res://src/scripts/StatsRenderer.gd").new()
	stats_renderer.name = "StatsRenderer"
	add_child(stats_renderer)
	stats_renderer.setup({
		"combat_stats_panel": combat_stats_panel,
		"skill_stats_panel": skill_stats_panel,
		"player": player,
	})

	tut = load("res://src/scripts/TutorialManager.gd").new()
	tut.name = "TutorialManager"
	add_child(tut)
	tut.setup({
		"owner": self,
		"enemy_sprite": enemy_sprite,
		"xp_bar": xp_bar,
		"stage_label": stage_label,
		"player": player,
		"enemy_hud": enemy_hud,
		"hand_texture": TUTORIAL_HAND_TEXTURE,
	})
	tut.request_timer_stop.connect(func():
		player_timer.stop()
		enemy_timer.stop()
	)
	tut.request_timer_start.connect(func():
		player_timer.wait_time = player.get_attack_speed()
		player_timer.start()
		enemy_timer.start()
	)

	_init_admob()
	_configure_touch_mouse_filters()
	enemy_hud.hide_legacy()

	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_music()
	
	victory_ui.visible = false
	
	# UI Connections
	player.gold_changed.connect(func(g): 
		gold_label.text = format_number(g)
		vfx.animate_label(gold_label)
	)
	player.health_changed.connect(func(c, m):	  
		hp_label.text = "HP: %s/%s" % [format_number(c), format_number(m)]
		player_hp_bar.min_value = 0
		player_hp_bar.max_value = m
		_tween_bar(player_hp_bar, float(c))
		enemy_hud.update_hp_bar_style(player_hp_bar)
		vfx.animate_label(hp_label)
		_update_consumables_ui() # Refresh potion button on HP change
		# Near Death Experience trigger
		var hp_ratio = float(c) / float(m) if m > 0 else 1.0
		vfx.set_near_death(hp_ratio < vfx.NEAR_DEATH_THRESHOLD and c > 0)
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
	bottom_nav.setup_navigation(_add_button_juice)
	
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
		vfx.spawn_floating_text(msg, Color.ORANGE_RED)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_error_sound()
	)
	
	# START MODE SELECTION
	var loaded_between_fights = false
	if startup_mode == "new_game":
		spawn_enemy()
		# Show tutorial on first run
		tut.call_deferred("show_tutorial")
	else:
		var load_result = load_game()
		if load_result is Dictionary:
			loaded_between_fights = load_result.get("between_fights", false)
		elif not load_result:
			print("WARN: load_game failed, starting fresh")
			spawn_enemy()
			tut.call_deferred("show_tutorial")
	
	# Always force a full UI refresh after initialization
	call_deferred("_force_ui_refresh_after_load")
	
	_update_consumables_ui()
	_update_inventory_ui()
	stats_renderer.update_stats()
	player.skills_updated.connect(stats_renderer.update_stats)
	player.health_changed.connect(func(_c, _m): stats_renderer.update_stats())
	player.gold_changed.connect(func(_g): stats_renderer.update_stats())
	
	if loaded_between_fights:
		# Resume at victory screen — don't start combat
		in_combat = false
		_set_combat_hud_visible(false)
		enemy_sprite.visible = false
		click_area.visible = false
		_update_loot_summary()
		_show_victory_popup()
	else:
		_start_combat()

func _set_combat_hud_visible(visible_state: bool):
	var top_hud = get_node_or_null("../CanvasLayer/TopHUD")
	var mid_hud = get_node_or_null("../CanvasLayer/MidHUD")
	var enemy_floating_ui = get_node_or_null("CanvasLayer/EnemyFloatingUI")
	if enemy_floating_ui == null:
		enemy_floating_ui = get_node_or_null("../CanvasLayer/EnemyFloatingUI")
	if top_hud:
		top_hud.visible = visible_state
	if mid_hud:
		mid_hud.visible = visible_state
	if enemy_floating_ui:
		enemy_floating_ui.visible = visible_state

	# Fallback: ensure individual enemy HUD controls follow the same state.
	if enemy_nameplate_label:
		enemy_nameplate_label.visible = visible_state
	if enemy_hp_bar:
		enemy_hp_bar.visible = visible_state
	if enemy_action_bar:
		enemy_action_bar.visible = visible_state

func _configure_touch_mouse_filters():
	# Non-interactive wrappers should ignore touch entirely.
	var ignore_nodes = [
		get_node_or_null("CanvasLayer/TopHUD"),
		get_node_or_null("CanvasLayer/TopHUD/VBox"),
		get_node_or_null("CanvasLayer/TopHUD/VBox/TopBar"),
		get_node_or_null("CanvasLayer/TopHUD/VBox/StageLabel"),
		get_node_or_null("CanvasLayer/TopHUD/VBox/InfoLabel"),
		get_node_or_null("CanvasLayer/MidHUD"),
		get_node_or_null("CanvasLayer/MidHUD/VBox"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/XPRowMargin"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/XPRowMargin/XPContainer/XPIcon"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/XPRowMargin/XPContainer/XPBar"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/XPRowMargin/XPContainer/XPLabel"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/PlayerHPContainer/PlayerHPBar"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/PlayerHPContainer/PlayerHPBar/HPLabel"),
		get_node_or_null("CanvasLayer/EnemyFloatingUI"),
		get_node_or_null("CanvasLayer/EnemyFloatingUI/EnemyFloatName"),
		get_node_or_null("CanvasLayer/EnemyFloatingUI/EnemyFloatHPBar"),
		get_node_or_null("CanvasLayer/EnemyFloatingUI/EnemyFloatAttackBar"),
	]
	for node in ignore_nodes:
		if node and node is Control:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Containers with interactive children should pass through empty space.
	var pass_nodes = [
		get_node_or_null("CanvasLayer/MidHUD/VBox/GoldContainer"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/XPRowMargin/XPContainer"),
		get_node_or_null("CanvasLayer/MidHUD/VBox/PlayerHPContainer"),
		get_node_or_null("../BottomNavLayer/BottomPanel"),
		get_node_or_null("../BottomNavLayer/BottomPanel/BottomLayout/ContentArea/TabContainer"),
	]
	for node in pass_nodes:
		if node and node is Control:
			node.mouse_filter = Control.MOUSE_FILTER_PASS

	# Explicitly keep main tap areas interactive.
	if click_area:
		click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	if victory_ui:
		victory_ui.mouse_filter = Control.MOUSE_FILTER_STOP

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

func _fix_parallax_sizes():
	var root_size = get_viewport().get_visible_rect().size
	if root_size.x < 100: 
		root_size = Vector2(540, 960) # fallback

	if jungle_base_bg:
		jungle_base_bg.set_anchors_preset(Control.PRESET_TOP_LEFT)
		jungle_base_bg.size = root_size
		jungle_base_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		jungle_base_bg.stretch_mode = 6
	
	if temple_bg:
		temple_bg.set_anchors_preset(Control.PRESET_TOP_LEFT)
		temple_bg.size = root_size
		temple_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		temple_bg.stretch_mode = 6

func _update_biome_bg():
	"""Switch visible biome background based on stage."""
	if not jungle_base_bg and not temple_bg:
		return
	if current_stage <= 14:
		if jungle_base_bg:
			jungle_base_bg.visible = true
		if temple_bg:
			temple_bg.visible = false
	elif current_stage <= 20:
		if jungle_base_bg:
			jungle_base_bg.visible = false
		if temple_bg:
			temple_bg.visible = true
			temple_bg.texture = bg_temple
	elif current_stage <= 40:
		if jungle_base_bg:
			jungle_base_bg.visible = false
		if temple_bg:
			temple_bg.visible = true
			temple_bg.texture = bg_temple
	else:
		# Stage 41+: mixed — keep temple for now.
		if jungle_base_bg:
			jungle_base_bg.visible = false
		if temple_bg:
			temple_bg.visible = true
			temple_bg.texture = bg_temple

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
	# Action Bar UI Update
	if in_combat and enemy_action_bar and enemy_timer and not enemy_timer.is_stopped():
		var progress = 1.0 - (enemy_timer.time_left / enemy_timer.wait_time)
		enemy_action_bar.value = progress

	# DPS tracking
	if in_combat:
		dps_timer += delta
		if dps_timer >= 1.0:
			current_dps = dps_damage_total / dps_timer
			if dps_label:
				dps_label.text = "DPS: %s" % format_number(int(current_dps))
			dps_damage_total = 0.0
			dps_timer = 0.0

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
		"last_save_time": Time.get_unix_time_from_system(),
		"prestige_level": player.prestige_level,
		"soul_shards": player.soul_shards,
		"daily_last_claim": player.daily_last_claim,
		"daily_streak": player.daily_streak,
		"player": {
			"max_hp": player.max_hp,
			"current_hp": player.current_hp,
			"gold": player.gold,
			"xp": player.xp,
			"level": player.level,
			"xp_required": player.xp_required,
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
	
	# Restore prestige data (persists across rebirths)
	player.prestige_level = int(data.get("prestige_level", 0))
	player.soul_shards = int(data.get("soul_shards", 0))
	player.daily_last_claim = str(data.get("daily_last_claim", ""))
	player.daily_streak = int(data.get("daily_streak", 0))
	
	player.max_hp = player_data["max_hp"]
	player.current_hp = player_data["current_hp"]
	player.gold = player_data["gold"]
	player.xp = int(player_data.get("xp", 0))
	player.level = int(player_data.get("level", 1))
	player.xp_required = int(player_data.get("xp_required", 20))
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
	# Offline rewards
	_check_offline_rewards(data)
	# Daily login check
	_check_daily_login()
	# Force full UI refresh after load
	call_deferred("_force_ui_refresh_after_load")
	print("Game loaded from Slot %d!" % slot)
	return {"success": true, "between_fights": between}


func _force_ui_refresh_after_load():
	# Deferred to ensure all @onready nodes are fully ready
	hp_label.text = "HP: %s/%s" % [format_number(player.current_hp), format_number(player.max_hp)]
	player_hp_bar.min_value = 0
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.current_hp
	enemy_hud.update_hp_bar_style(player_hp_bar)
	gold_label.text = format_number(player.gold)
	player.health_changed.emit(player.current_hp, player.max_hp)
	player.gold_changed.emit(player.gold)
	player.skills_updated.emit()
	_update_inventory_ui()
	_update_consumables_ui()
	stats_renderer.update_stats()
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
		inventory_grid.remove_child(child)
		child.queue_free()
	_selected_inventory_slot = null
	
	var slots_added := 0

	# Display Resources
	for res_id in player.resources.keys():
		var count = player.resources[res_id]
		if count > 0:
			var slot = inventory_slot_scene.instantiate()
			inventory_grid.add_child(slot)
			var tex = _get_resource_icon(res_id)
			var data := {"type": "resource", "name": res_id.capitalize(), "count": count, "desc": _get_resource_desc(res_id)}
			slot.set_item(tex, count, Color.MEDIUM_PURPLE, data)
			slot.slot_pressed.connect(_on_inventory_slot_pressed.bind(slot))
			slots_added += 1

	# Display Equipment
	for item in player.inventory:
		var slot = inventory_slot_scene.instantiate()
		inventory_grid.add_child(slot)
		var icon_p = item.icon_path
		if icon_p == "": icon_p = "res://assets/icons/new_icons/Icons 512x512/24.png"
		var tex = load(icon_p)
		var is_equipped = (item == player.equipped_item)
		var rarity_col = item.get_color()
		if is_equipped: rarity_col = Color.GOLD
		var data := {"type": "equipment", "name": item.name, "damage": item.damage_bonus, "rarity": item.rarity, "equipped": is_equipped}
		slot.set_item(tex, 1, rarity_col, data)
		slot.slot_pressed.connect(_on_inventory_slot_pressed.bind(slot))
		slots_added += 1

	# Fill empty slots up to 24 (6 columns x 4 rows)
	var total_slots := maxi(24, slots_added)
	for i in range(slots_added, total_slots):
		var empty_slot := PanelContainer.new()
		empty_slot.custom_minimum_size = Vector2(48, 48)
		var es := StyleBoxFlat.new()
		es.bg_color = Color(0.15, 0.12, 0.1, 0.4)
		es.set_corner_radius_all(4)
		es.set_border_width_all(1)
		es.border_color = Color(0.3, 0.25, 0.2, 0.3)
		empty_slot.add_theme_stylebox_override("panel", es)
		inventory_grid.add_child(empty_slot)

	# Ensure description panel exists
	_ensure_item_desc_panel()
	_update_item_desc_panel({})

func _get_resource_desc(res_id: String) -> String:
	match res_id:
		"bandages": return "Used to upgrade STR and GREED skills."
		"venom": return "Used to upgrade CRIT and SPEED skills."
		"relic_shards": return "Used to upgrade DEF skill."
	return "A crafting resource."

func _ensure_item_desc_panel():
	if _item_desc_panel and is_instance_valid(_item_desc_panel):
		return
	# Add desc panel INSIDE the Inventory ScrollContainer, after the grid
	# This way it doesn't create a new tab in TabContainer
	var grid_parent = inventory_grid.get_parent()
	if not grid_parent:
		return

	# Find or create InvWrapper
	var wrapper: VBoxContainer = null
	if grid_parent.name == "InvWrapper":
		# Already wrapped from a previous call
		wrapper = grid_parent
	else:
		# First time: grid is direct child of ScrollContainer — wrap it
		wrapper = VBoxContainer.new()
		wrapper.name = "InvWrapper"
		wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		wrapper.add_theme_constant_override("separation", 4)
		grid_parent.remove_child(inventory_grid)
		wrapper.add_child(inventory_grid)
		grid_parent.add_child(wrapper)

	_item_desc_panel = PanelContainer.new()
	_item_desc_panel.name = "ItemDescPanel"
	_item_desc_panel.custom_minimum_size = Vector2(0, 60)
	_item_desc_panel.visible = false
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.22, 0.17, 0.12, 0.95)
	ps.set_corner_radius_all(5)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.67, 0.54, 0.38, 0.95)
	ps.content_margin_left = 10
	ps.content_margin_top = 6
	ps.content_margin_right = 10
	ps.content_margin_bottom = 6
	_item_desc_panel.add_theme_stylebox_override("panel", ps)

	_item_desc_label = RichTextLabel.new()
	_item_desc_label.bbcode_enabled = true
	_item_desc_label.fit_content = true
	_item_desc_label.scroll_active = false
	_item_desc_label.add_theme_font_size_override("normal_font_size", 12)
	_item_desc_label.add_theme_color_override("default_color", Color(0.93, 0.93, 0.9))
	_item_desc_panel.add_child(_item_desc_label)

	wrapper.add_child(_item_desc_panel)

func _on_inventory_slot_pressed(_data: Dictionary, slot: InventorySlot):
	if _selected_inventory_slot == slot:
		# Deselect
		slot.set_selected(false)
		_selected_inventory_slot = null
		_update_item_desc_panel({})
		return
	if _selected_inventory_slot and is_instance_valid(_selected_inventory_slot):
		_selected_inventory_slot.set_selected(false)
	_selected_inventory_slot = slot
	slot.set_selected(true)
	_update_item_desc_panel(_data)

func _update_item_desc_panel(data: Dictionary):
	if not _item_desc_panel or not is_instance_valid(_item_desc_panel):
		return
	if data.size() == 0:
		_item_desc_panel.visible = false
		return
	_item_desc_panel.visible = true
	var bbcode := ""
	if data.get("type") == "resource":
		bbcode = "[b][color=#c8a0e0]%s[/color][/b]  x%d\n%s" % [data.get("name", ""), data.get("count", 0), data.get("desc", "")]
	elif data.get("type") == "equipment":
		var rarity_col := _rarity_hex(data.get("rarity", "Common"))
		var equip_tag := "  [color=#ffd700][b]EQUIPPED[/b][/color]" if data.get("equipped", false) else ""
		bbcode = "[b][color=%s]%s[/color][/b]%s\n+%d DMG  ·  %s" % [rarity_col, data.get("name", ""), equip_tag, data.get("damage", 0), data.get("rarity", "Common")]
	_item_desc_label.text = bbcode

func _rarity_hex(rarity: String) -> String:
	match rarity:
		"Common": return "#ffffff"
		"Rare": return "#00e5ff"
		"Epic": return "#c060ff"
		"Legendary": return "#ff9800"
	return "#ffffff"

func _get_icon_texture(path: String) -> Texture2D:
	if not icon_texture_cache.has(path):
		icon_texture_cache[path] = load(path)
	return icon_texture_cache[path]

func _get_resource_icon(resource_id: String) -> Texture2D:
	var path = resource_icon_paths.get(resource_id, "res://assets/sprites/icon.svg")
	return _get_icon_texture(path)

func _update_consumables_ui():
	var potion_btn = %PotionButton
	if potion_btn:
		var count = player.consumables.get("hp_potion", 0)
		potion_btn.icon = POTION_ICON_TEXTURE
		potion_btn.text = "x%d" % count
		# Keep icon look consistent (disabled state dims icon and looked like a different sprite).
		potion_btn.disabled = false
		
		# Connect action if not already connected
		if not potion_btn.pressed.is_connected(_on_potion_button_pressed):
			potion_btn.pressed.connect(_on_potion_button_pressed)
			_add_button_juice(potion_btn)


func _add_button_juice(btn: BaseButton):
	if not btn: return
	btn.pivot_offset = btn.size / 2
	
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
	var count = player.consumables.get("hp_potion", 0)
	if count <= 0:
		vfx.spawn_floating_text("NO POTIONS", Color.ORANGE_RED)
		return
	if player.current_hp >= player.max_hp:
		vfx.spawn_floating_text("ALREADY FULL HP", Color.ORANGE)
		return

	if player.use_consumable("hp_potion"):
		var heal_amount = max(30, int(player.max_hp * 0.3))
		vfx.spawn_floating_text("POTION +%d" % heal_amount, Color.SPRING_GREEN)
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_coin_sound() # Temporary sound
		_update_consumables_ui()

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
		enemy_hud.show_boss_greeting(boss_data.greeting)
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
		
	var spawn_y = 202.0 + (target_size / 2.0) + 4.0
	enemy_sprite.position = Vector2(180, spawn_y)
	vfx.original_enemy_pos = enemy_sprite.position
	
	# Switch biome background based on stage
	_update_biome_bg()
	
	vfx.start_idle_animation()
		
	current_enemy.setup_enemy(hp, dmg, gold, 10 + current_stage, res_type)
	current_enemy.enemy_name = enemy_name
	if saved_hp != -1:
		current_enemy.current_hp = saved_hp
		
	current_enemy.hp_changed.connect(enemy_hud.on_hp_changed)
	current_enemy.died.connect(_on_enemy_died)
	
	stage_label.text = "Stage %d" % current_stage
	enemy_hud.hide_legacy()
	notif.update_stage_info(current_stage, boss_roster)
	# Single floating enemy UI: name/lvl + hp bar + attack bar
	if enemy_nameplate_label:
		var display = enemy_name.replace("BOSS: ", "").replace("ELITE: ", "").replace("ULTIMATE BOSS: ", "")
		enemy_nameplate_label.text = "%s – Lvl %d" % [display, current_stage]
		enemy_nameplate_label.visible = true
	if enemy_hp_bar: enemy_hp_bar.visible = true
	if enemy_action_bar: enemy_action_bar.visible = true
	enemy_action_bar.min_value = 0.0
	enemy_action_bar.max_value = 1.0
	enemy_action_bar.value = 0.0
	enemy_hud.on_hp_changed(current_enemy.current_hp, hp)

# Adrenaline mechanic
var adrenaline_clicks: int = 0
const ADRENALINE_THRESHOLD: int = 50
const ADRENALINE_DURATION: float = 5.0
var adrenaline_timer_left: float = 0.0
var adrenaline_active: bool = false

func _on_click_area_pressed():
	if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_COMBAT_TAPS:
		if tut.tutorial_click_cooldown:
			return
		tut.tutorial_click_cooldown = true
		_on_player_attack(true)
		tut.tutorial_tap_count += 1
		if tut.tutorial_tap_count >= 3:
			tut.call_deferred("enter_auto_attack_step", current_enemy)
		await get_tree().create_timer(0.16).timeout
		tut.tutorial_click_cooldown = false
		return

	_on_player_attack(true)
	
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
	vfx.spawn_floating_text("ADRENALINE x2 DMG", Color.GOLDENROD)
	vfx.spawn_floating_text("ADRENALINE ACTIVE", Color.ORANGE_RED)
	vfx.vibrate(150)

	# Timer to stop
	await get_tree().create_timer(ADRENALINE_DURATION).timeout
	adrenaline_active = false
	adrenaline_clicks = 0
	vfx.spawn_floating_text("Adrenaline ended", Color.GRAY)

func _on_player_attack(from_click: bool = false):
	if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_COMBAT_TAPS and not from_click:
		return
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
			vfx.spawn_floating_text("MISS", Color.GRAY)
		else:
			vfx.spawn_floating_text(result + ("!!" if is_crit else ""), Color.YELLOW if not is_crit else Color.ORANGE, is_crit)
			vfx.play_hit_effect(is_crit)
			# Vibration feedback on hit
			vfx.vibrate(30 if not is_crit else 60)
			# Thorns: reflect damage to player
			if player.thorns_percent > 0 and current_enemy:
				var reflect_dmg = int(dmg * player.thorns_percent)
				if reflect_dmg > 0:
					player.current_hp = max(1, player.current_hp - reflect_dmg)
					player.health_changed.emit(player.current_hp, player.max_hp)
					vfx.spawn_floating_text("THORNS -%d" % reflect_dmg, Color.DARK_RED)
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
		flash_tween.parallel().tween_property(enemy_sprite, "position:y", vfx.original_enemy_pos.y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		if result == "DODGED":
			vfx.spawn_floating_text("DODGED", Color.AQUA)
		else:
			var color = Color.WHITE if "BLOCKED" in result else Color(1, 0.2, 0.2)
			vfx.spawn_floating_text(result, color)
			
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

func _on_enemy_died(_xp, gold, res_type = ""):
	# Reset near-death vignette immediately on kill
	vfx.set_near_death(false)
	# Vibrate on kill
	vfx.vibrate(100)
	# Immediately dismiss boss greeting & floating texts so they don't leak over reward screen
	enemy_hud.dismiss_greeting()
	vfx.clear_floating_texts()
	# Reset loot summary for this kill
	# LOOT BUFF: +20% gold globalnie od stage 1
	var final_gold = int(gold * 1.2)
	kill_gold = final_gold
	kill_xp = 0
	kill_resource = ""
	kill_resource_amount = 0
	kill_potion = false
	kill_item = null
	
	player.gain_gold(final_gold)
	
	# XP Balance: Stage 1 guarantees level up, +20% globalnie
	var xp_reward = 20 if current_stage == 1 else int((15 + (current_stage * 5)) * 1.2)
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
		# LOOT BUFF: +20% resource drop (ceil)
		drop_amount = int(ceil(drop_amount * 1.2))
		player.add_resource(res_type, drop_amount)
		kill_resource = res_type
		kill_resource_amount = drop_amount
		vfx.spawn_floating_text("+%d %s" % [drop_amount, res_type.capitalize()], Color.MEDIUM_PURPLE)
			
	# POTION DROP (48% chance, buffed z 40%)
	if randf() < 0.48:
		player.consumables["hp_potion"] += 1
		kill_potion = true
		vfx.spawn_floating_text("LOOT: HP POTION", Color.GREEN_YELLOW)
		player.consumables_updated.emit()
	
	# Force clean inventory from unauthorized "junk" items
	player.inventory.clear()
	player.equipped_item = null
	
	notif.update_stage_info(current_stage, boss_roster)
	enemy_hud.hide_legacy()
	
	# Hide enemy sprite so it doesn't bleed through reward/level-up screens
	enemy_sprite.visible = false
	click_area.visible = false
	if enemy_nameplate_label: enemy_nameplate_label.visible = false
	if enemy_hp_bar: enemy_hp_bar.visible = false
	if enemy_action_bar: enemy_action_bar.visible = false
	vfx.stop_idle_animation()
	
	# Boss Death Spectacle — screen shake + slow-mo + gold burst
	var is_boss_kill = current_stage % 5 == 0
	if is_boss_kill:
		vfx.play_boss_death_spectacle()
	
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
	
	# Enemy died -> show ONLY victory screen
	_update_loot_summary()
	if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_AUTO_ATTACK:
		await tut.show_xp_hint_step()
	# Delay popups after boss kill so the death spectacle flash finishes
	if is_boss_kill:
		await get_tree().create_timer(0.7).timeout
	if level_up_sequence_pending:
		level_up_sequence_pending = false
		victory_popup_pending_after_reward = true
		if tut.tutorial_active and tut.tutorial_step <= tut.TUTORIAL_AUTO_ATTACK:
			tut.tutorial_step = tut.TUTORIAL_LEVEL_UP
		_show_card_choice_popup()
	else:
		_show_victory_popup()

func _on_player_leveled_up(_new_level):
	level_up_sequence_pending = true
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_coin_sound()

func _show_card_choice_popup():
	if ui_state == UI_STATE_REWARD:
		return
	var card_scene = load("res://src/scenes/CardChoiceScene.tscn")
	if not card_scene:
		return
	var instance = card_scene.instantiate()
	if not instance:
		return
	ui_state = UI_STATE_REWARD
	reward_popup_node = instance
	tut.clear_overlay()
	vfx.clear_floating_texts()
	enemy_hud.dismiss_greeting()
	_ensure_overlay_background_is_visible()
	_set_combat_hud_visible(false)
	var efu = get_node_or_null("../CanvasLayer/EnemyFloatingUI")
	if efu: efu.visible = false
	victory_ui.visible = false
	%CanvasLayer.add_child(instance)
	if instance.has_signal("choice_completed"):
		instance.connect("choice_completed", Callable(self, "_on_card_choice_completed"), CONNECT_ONE_SHOT)
	if instance.has_method("setup"):
		var setup_cfg := {}
		if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_LEVEL_UP:
			setup_cfg = {
				"tutorial_mode": true,
				"forced_upgrade_id": "str",
				"guide_text": "Choose your reward!"
			}
		instance.setup(player, setup_cfg)

func _on_card_choice_completed():
	reward_popup_node = null
	if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_LEVEL_UP:
		tut.tutorial_step = tut.TUTORIAL_STAGE_PROGRESS
	if victory_popup_pending_after_reward:
		victory_popup_pending_after_reward = false
		_show_victory_popup()
	else:
		ui_state = UI_STATE_COMBAT
		_advance_to_next_stage()

func _show_victory_popup():
	ui_state = UI_STATE_VICTORY
	tut.clear_overlay()
	vfx.clear_floating_texts()
	enemy_hud.dismiss_greeting()
	_ensure_overlay_background_is_visible()
	_set_combat_hud_visible(false)
	var enemy_floating_ui = get_node_or_null("CanvasLayer/EnemyFloatingUI")
	if enemy_floating_ui == null:
		enemy_floating_ui = get_node_or_null("../CanvasLayer/EnemyFloatingUI")
	if enemy_floating_ui:
		enemy_floating_ui.visible = false
	if reward_popup_node and is_instance_valid(reward_popup_node):
		reward_popup_node.queue_free()
		reward_popup_node = null
	# Rebirth button (dynamic — shown only when eligible)
	_update_rebirth_button()
	_show_victory_popup_animated()
	if _banner_ad:
		_banner_ad.show()
	var is_boss_stage = (current_stage % 5 == 0)
	if not is_boss_stage:
		_maybe_show_interstitial_after_kill()

func _show_victory_popup_animated():
	if not victory_ui:
		return
	if victory_ui_tween:
		victory_ui_tween.kill()
	victory_ui.visible = true
	victory_ui.modulate = Color(1, 1, 1, 0)
	victory_ui.scale = Vector2(0.94, 0.94)
	victory_ui.pivot_offset = victory_ui.size * 0.5

	# Disable buttons during 1s buffer to prevent misclicks
	var victory_buttons: Array[Button] = []
	for btn_name in ["NextLevelButton", "OpenTreeButton", "WatchAdButton", "MainMenuButton"]:
		var btn = get_node_or_null("%" + btn_name)
		if btn and btn is Button:
			victory_buttons.append(btn)
			btn.disabled = true
			btn.modulate.a = 0.4

	victory_ui_tween = create_tween()
	victory_ui_tween.tween_property(victory_ui, "modulate:a", 1.0, 0.16)
	victory_ui_tween.parallel().tween_property(victory_ui, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Victory celebration text
	var victory_label := Label.new()
	victory_label.text = "VICTORY!"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.add_theme_font_size_override("font_size", 22)
	victory_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	var vl_ls := LabelSettings.new()
	vl_ls.outline_size = 3
	vl_ls.outline_color = Color(0, 0, 0, 0.9)
	victory_label.label_settings = vl_ls
	victory_label.anchor_left = 0.0
	victory_label.anchor_right = 1.0
	victory_label.anchor_top = 0.1
	victory_label.offset_top = -10
	victory_ui.add_child(victory_label)
	UIAnimations.scale_in(victory_label, 0.35)

	# 1s buffer then enable buttons
	await get_tree().create_timer(1.0).timeout

	# Remove celebration text
	if is_instance_valid(victory_label):
		var fade_t = create_tween()
		fade_t.tween_property(victory_label, "modulate:a", 0.0, 0.2)
		fade_t.finished.connect(func():
			if is_instance_valid(victory_label):
				victory_label.queue_free()
		)

	# Enable buttons with bounce animation
	for btn in victory_buttons:
		if is_instance_valid(btn):
			btn.disabled = false
			var bt := create_tween()
			bt.tween_property(btn, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			btn.pivot_offset = btn.size * 0.5
			UIAnimations.bounce_control(btn, 1.12, 0.18)

	if _next_stage_label and is_instance_valid(_next_stage_label):
		_next_stage_label.free()
		_next_stage_label = null
	var vbox := victory_ui.get_node_or_null("VBox")
	if vbox:
		_next_stage_label = Label.new()
		_next_stage_label.text = _get_next_stage_preview()
		_next_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_next_stage_label.add_theme_font_size_override("font_size", 11)
		var nl_ls := LabelSettings.new()
		nl_ls.font_color = Color(0.85, 0.75, 0.45, 0.9)
		nl_ls.outline_size = 2
		nl_ls.outline_color = Color(0, 0, 0, 0.7)
		_next_stage_label.label_settings = nl_ls
		_next_stage_label.layout_mode = 2
		_next_stage_label.modulate.a = 0.0
		vbox.add_child(_next_stage_label)
		vbox.move_child(_next_stage_label, 2)
		var nl_t := create_tween()
		nl_t.tween_property(_next_stage_label, "modulate:a", 1.0, 0.3).set_delay(0.1)

func _get_next_stage_preview() -> String:
	var next := current_stage + 1
	if next > 50:
		return "All stages complete!"
	if next == 50:
		return "→ Stage 50  ★  FINAL BOSS"
	if boss_roster.has(next):
		return "→ Stage %d  ⚔  BOSS: %s" % [next, boss_roster[next]["name"]]
	if next % 5 == 0:
		return "→ Stage %d  ⚔  Boss Fight!" % next
	var biome := "Jungle" if next <= 14 else "Temple"
	return "→ Stage %d  —  %s" % [next, biome]

func _ensure_overlay_background_is_visible():
	_fix_parallax_sizes()
	_update_biome_bg()

func _on_next_level_button_pressed():
	if ui_state != UI_STATE_VICTORY:
		return
	# Juice: animate victory panel out before advancing
	if victory_ui and is_instance_valid(victory_ui):
		var exit_t: Tween = create_tween().set_parallel(true)
		exit_t.tween_property(victory_ui, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_SINE)
		exit_t.tween_property(victory_ui, "scale", Vector2(1.06, 1.06), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await exit_t.finished
	_advance_to_next_stage()

func _on_main_menu_button_pressed():
	if ui_state != UI_STATE_VICTORY:
		return
	save_game()
	vfx.set_near_death(false)
	get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")

func _advance_to_next_stage():
	save_game()
	vfx.play_stage_transition_flash()
	current_stage += 1
	# Tick down stage-based curses
	player.on_stage_advance()
	if player.active_curses.size() > 0:
		var names = player.get_active_curse_names()
		vfx.spawn_floating_text("Curses: %s" % ", ".join(names), Color.DARK_RED)
	spawn_enemy()
	_start_combat()

func _start_combat():
	Engine.time_scale = 1.0
	get_tree().paused = false
	ui_state = UI_STATE_COMBAT
	victory_popup_pending_after_reward = false
	_set_combat_hud_visible(true)
	enemy_sprite.visible = true
	enemy_sprite.modulate = Color(1, 1, 1, 1)
	vfx.play_battle_fade_in()
	_ensure_overlay_background_is_visible()
	victory_ui.visible = false
	victory_ui.modulate = Color(1, 1, 1, 1)
	victory_ui.scale = Vector2.ONE
	if reward_popup_node and is_instance_valid(reward_popup_node):
		reward_popup_node.queue_free()
		reward_popup_node = null
	in_combat = true
	# Ukryj banner podczas walki
	if _banner_ad: _banner_ad.hide()
	dps_damage_total = 0.0
	dps_timer = 0.0
	current_dps = 0.0
	if dps_label:
		dps_label.text = ""
	if enemy_action_bar:
		enemy_action_bar.value = 0.0
	player_timer.wait_time = player.get_attack_speed()
	player_timer.start()
	enemy_timer.start()
	# Start poison timer if player has poison curse
	_update_poison_timer()

	if tut.tutorial_active and tut.tutorial_step == tut.TUTORIAL_STAGE_PROGRESS:
		tut.call_deferred("show_stage_progress_step")

func _on_skills_updated():
	if player_timer:
		player_timer.wait_time = player.get_attack_speed()
		if not player_timer.is_stopped(): player_timer.start()

func _handle_player_death():
	print("PLAYER DIED - GAME OVER")
	vfx.vibrate(300)  # Strong vibration on death
	# Reset near-death effects before scene change
	vfx.set_near_death(false)
	# Don't save — last auto-save checkpoint (after previous kill) is preserved
	# Player chooses Continue (reload checkpoint) or New Game from title screen
	
	# Return to main menu
	var title_screen = load("res://src/scenes/TitleScreen.gd")
	if title_screen:
		title_screen.last_run_result = "DEFEAT"
	
	get_tree().change_scene_to_file("res://src/scenes/TitleScreen.tscn")

# === PRESTIGE / REBIRTH SYSTEM ===
const REBIRTH_MIN_STAGE := 25

func _should_show_rebirth() -> bool:
	return current_stage >= REBIRTH_MIN_STAGE

func _get_rebirth_shards() -> int:
	return int(current_stage / 5)

func _on_rebirth_pressed():
	if ui_state != UI_STATE_VICTORY:
		return
	var shards = _get_rebirth_shards()
	_show_rebirth_confirmation(shards)

func _show_rebirth_confirmation(shards: int):
	var overlay := CanvasLayer.new()
	overlay.layer = 160
	add_child(overlay)
	
	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.7)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)
	
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -140
	panel.offset_top = -120
	panel.offset_right = 140
	panel.offset_bottom = 120
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.15, 0.1, 0.2, 0.95)
	ps.set_corner_radius_all(8)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.7, 0.5, 1.0)
	ps.content_margin_left = 16
	ps.content_margin_right = 16
	ps.content_margin_top = 12
	ps.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", ps)
	overlay.add_child(panel)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = "REBIRTH"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	var tls := LabelSettings.new()
	tls.outline_size = 3
	tls.outline_color = Color.BLACK
	title_lbl.label_settings = tls
	vbox.add_child(title_lbl)
	
	var desc_lbl := Label.new()
	desc_lbl.text = "Reset all progress and start from Stage 1.\n\nYou will earn %d Soul Shards.\nEach shard gives +2%% DMG and +3%% Gold permanently.\n\nCurrent shards: %d\nAfter rebirth: %d" % [shards, player.soul_shards, player.soul_shards + shards]
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)
	
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)
	
	var cancel_btn := Button.new()
	cancel_btn.text = "CANCEL"
	cancel_btn.custom_minimum_size = Vector2(100, 40)
	cancel_btn.pressed.connect(overlay.queue_free)
	_add_button_juice(cancel_btn)
	btn_row.add_child(cancel_btn)
	
	var confirm_btn := Button.new()
	confirm_btn.text = "REBIRTH!"
	confirm_btn.custom_minimum_size = Vector2(100, 40)
	confirm_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_add_button_juice(confirm_btn)
	confirm_btn.pressed.connect(func():
		overlay.queue_free()
		_execute_rebirth(shards)
	)
	btn_row.add_child(confirm_btn)

func _execute_rebirth(shards: int):
	player.rebirth(shards)
	current_stage = 1
	save_game()
	# Restart the game scene cleanly
	get_tree().change_scene_to_file("res://src/scenes/node_2d.tscn")

var _rebirth_btn: Button = null

func _update_rebirth_button():
	# Remove old rebirth button if exists
	if _rebirth_btn and is_instance_valid(_rebirth_btn):
		_rebirth_btn.queue_free()
		_rebirth_btn = null
	if not _should_show_rebirth():
		return
	# Add rebirth button to VictoryUI VBox
	var vbox = victory_ui.get_node_or_null("VBox")
	if not vbox:
		return
	_rebirth_btn = Button.new()
	_rebirth_btn.text = "REBIRTH (+%d Shards)" % _get_rebirth_shards()
	_rebirth_btn.custom_minimum_size = Vector2(200, 50)
	_rebirth_btn.add_theme_color_override("font_color", Color(0.6, 0.3, 0.8))
	_add_button_juice(_rebirth_btn)
	_rebirth_btn.pressed.connect(_on_rebirth_pressed)
	vbox.add_child(_rebirth_btn)

# === OFFLINE PROGRESS / IDLE REWARDS ===
func _check_offline_rewards(data: Dictionary):
	var last_save = data.get("last_save_time", 0.0)
	if last_save <= 0.0:
		return
	var now = Time.get_unix_time_from_system()
	var elapsed = now - last_save
	if elapsed < 60:  # Less than 1 minute — skip
		return
	# Cap at 8 hours
	elapsed = min(elapsed, 28800.0)
	# Gold per second at 30% efficiency
	var gold_per_sec = GOLD_BASE * pow(GOLD_SCALE, current_stage) * 0.3
	var offline_gold = int(gold_per_sec * elapsed)
	if offline_gold <= 0:
		return
	player.gain_gold(offline_gold)
	# Show welcome back popup
	call_deferred("_show_offline_reward_popup", offline_gold, int(elapsed))

func _show_offline_reward_popup(gold_amount: int, seconds: int):
	var hours = seconds / 3600
	var mins = (seconds % 3600) / 60
	var time_str = ""
	if hours > 0:
		time_str = "%dh %dm" % [hours, mins]
	else:
		time_str = "%dm" % mins
	
	var overlay := CanvasLayer.new()
	overlay.layer = 155
	add_child(overlay)
	
	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.6)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)
	
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -130
	panel.offset_top = -80
	panel.offset_right = 130
	panel.offset_bottom = 80
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.12, 0.15, 0.08, 0.95)
	ps.set_corner_radius_all(8)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.8, 0.7, 0.3)
	ps.content_margin_left = 16
	ps.content_margin_right = 16
	ps.content_margin_top = 12
	ps.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", ps)
	overlay.add_child(panel)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = "WELCOME BACK!"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color.GOLD)
	var tls := LabelSettings.new()
	tls.outline_size = 3
	tls.outline_color = Color.BLACK
	title_lbl.label_settings = tls
	vbox.add_child(title_lbl)
	
	var desc := Label.new()
	desc.text = "You were away for %s.\nYour adventurers earned:\n\n%s Gold" % [time_str, format_number(gold_amount)]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	var ok_btn := Button.new()
	ok_btn.text = "COLLECT"
	ok_btn.custom_minimum_size = Vector2(140, 40)
	ok_btn.add_theme_color_override("font_color", Color.GOLD)
	_add_button_juice(ok_btn)
	ok_btn.pressed.connect(overlay.queue_free)
	vbox.add_child(ok_btn)

# === DAILY LOGIN / STREAK REWARDS ===
const DAILY_REWARDS := [
	{"gold": 50},
	{"gold": 100},
	{"gold": 200},
	{"gold": 500},
	{"gold": 1000},
	{"potions": 2},
	{"gold": 2000, "relic_shards": 5},
]

func _check_daily_login():
	var today = Time.get_date_string_from_system()
	if player.daily_last_claim == today:
		return  # Already claimed today
	# Check streak
	if player.daily_last_claim == "":
		player.daily_streak = 0
	else:
		var last_date = _parse_date(player.daily_last_claim)
		var today_date = _parse_date(today)
		var diff = today_date - last_date
		if diff > 2:  # Missed more than 1 day
			player.daily_streak = 0
	
	var day_index = player.daily_streak % DAILY_REWARDS.size()
	var reward = DAILY_REWARDS[day_index]
	player.daily_streak += 1
	player.daily_last_claim = today
	save_game()
	call_deferred("_show_daily_reward_popup", reward, player.daily_streak, day_index + 1)

func _parse_date(date_str: String) -> int:
	# Convert "YYYY-MM-DD" to day count for simple diff
	var parts = date_str.split("-")
	if parts.size() < 3:
		return 0
	return int(parts[0]) * 365 + int(parts[1]) * 30 + int(parts[2])

func _show_daily_reward_popup(reward: Dictionary, streak: int, day_num: int):
	var overlay := CanvasLayer.new()
	overlay.layer = 156
	add_child(overlay)
	
	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.6)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)
	
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -130
	panel.offset_top = -90
	panel.offset_right = 130
	panel.offset_bottom = 90
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.1, 0.12, 0.18, 0.95)
	ps.set_corner_radius_all(8)
	ps.set_border_width_all(2)
	ps.border_color = Color(0.3, 0.6, 1.0)
	ps.content_margin_left = 16
	ps.content_margin_right = 16
	ps.content_margin_top = 12
	ps.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", ps)
	overlay.add_child(panel)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = "DAILY REWARD"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	var tls := LabelSettings.new()
	tls.outline_size = 3
	tls.outline_color = Color.BLACK
	title_lbl.label_settings = tls
	vbox.add_child(title_lbl)
	
	var streak_lbl := Label.new()
	streak_lbl.text = "Day %d — Streak: %d" % [day_num, streak]
	streak_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak_lbl.add_theme_font_size_override("font_size", 11)
	streak_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(streak_lbl)
	
	# Reward description
	var reward_parts: Array[String] = []
	if reward.has("gold"):
		reward_parts.append("%s Gold" % format_number(int(reward["gold"])))
	if reward.has("potions"):
		reward_parts.append("%d HP Potions" % int(reward["potions"]))
	if reward.has("relic_shards"):
		reward_parts.append("%d Relic Shards" % int(reward["relic_shards"]))
	
	var reward_lbl := Label.new()
	reward_lbl.text = "\n".join(reward_parts)
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_lbl.add_theme_font_size_override("font_size", 13)
	reward_lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(reward_lbl)
	
	# Apply rewards
	if reward.has("gold"):
		player.gain_gold(int(reward["gold"]))
	if reward.has("potions"):
		player.consumables["hp_potion"] += int(reward["potions"])
		player.consumables_updated.emit()
	if reward.has("relic_shards"):
		player.add_resource("relic_shards", int(reward["relic_shards"]))
	
	var ok_btn := Button.new()
	ok_btn.text = "CLAIM"
	ok_btn.custom_minimum_size = Vector2(140, 40)
	ok_btn.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	_add_button_juice(ok_btn)
	ok_btn.pressed.connect(overlay.queue_free)
	vbox.add_child(ok_btn)

func _on_open_skill_tree():
	if ui_state != UI_STATE_VICTORY:
		return
	if !skill_tree_scene: return
	vfx.clear_floating_texts()
	victory_ui.hide()
	# Pause game while browsing skill tree
	get_tree().paused = true
	var tree = skill_tree_scene.instantiate()
	%CanvasLayer.add_child(tree)
	tree.tree_exited.connect(func():
		if ui_state == UI_STATE_VICTORY:
			victory_ui.show()
	)
	tree.setup(player)

func _on_settings_hud_pressed():
	vfx.clear_floating_texts()
	get_tree().paused = true
	var settings_layer := CanvasLayer.new()
	settings_layer.layer = 150
	add_child(settings_layer)
	var settings = load("res://src/scenes/SettingsScene.tscn").instantiate()
	settings.tree_exited.connect(settings_layer.queue_free)
	settings_layer.add_child(settings)
	settings.setup()

# === WATCH AD FOR FULL HEAL ===
var ad_uses_this_stage: int = 0
const MAX_AD_PER_STAGE: int = 1
const DEBUG_FORCE_FAKE_ADS: bool = false # PRODUCTION MODE

# AdMob Rewarded Ad
var _rewarded_ad: RewardedAd = null
var _admob_available: bool = false
const REWARDED_AD_UNIT_ID = "ca-app-pub-4067533100503154/9484519330"

# AdMob Banner Ad (ISSUE-02) — Joana Indiana
const BANNER_AD_UNIT_ID = "ca-app-pub-4067533100503154/1590900646"
var _banner_ad: AdView = null

# AdMob Interstitial Ad (ISSUE-03)
const INTERSTITIAL_FREQUENCY: int = 8
const INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-4067533100503154/7266733306"
var _interstitial_ad: InterstitialAd = null
var _kills_since_interstitial: int = 0

func _init_admob():
	if DEBUG_FORCE_FAKE_ADS:
		print("[AdMob] Mode: FAKE ADS ENABLED")
		_admob_available = false
		return
		
	print("[AdMob] OS.get_name() = %s" % OS.get_name())
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Step 1: Request UMP consent before initializing ads
		_request_consent()

func _request_consent():
	print("[AdMob/UMP] Requesting consent info update...")
	var params := ConsentRequestParameters.new()
	UserMessagingPlatform.consent_information.update(
		params,
		_on_consent_update_success,
		_on_consent_update_failure
	)

func _on_consent_update_success():
	print("[AdMob/UMP] Consent info updated OK")
	var status: int = UserMessagingPlatform.consent_information.get_consent_status()
	print("[AdMob/UMP] Consent status: %d" % status)
	if status == ConsentInformation.ConsentStatus.REQUIRED:
		if UserMessagingPlatform.consent_information.get_is_consent_form_available():
			print("[AdMob/UMP] Consent form available — loading...")
			UserMessagingPlatform.load_consent_form(_on_consent_form_loaded, _on_consent_form_load_failed)
		else:
			print("[AdMob/UMP] Consent required but form not available — proceeding")
			_start_admob_after_consent()
	else:
		# NOT_REQUIRED or OBTAINED — proceed directly
		print("[AdMob/UMP] Consent not required or already obtained — proceeding")
		_start_admob_after_consent()

func _on_consent_update_failure(error: FormError):
	print("[AdMob/UMP] Consent update failed: [%d] %s" % [error.error_code, error.message])
	# Proceed anyway — ads may still work, just without personalization
	_start_admob_after_consent()

func _on_consent_form_loaded(form: ConsentForm):
	print("[AdMob/UMP] Consent form loaded — showing...")
	form.show(_on_consent_form_dismissed)

func _on_consent_form_load_failed(error: FormError):
	print("[AdMob/UMP] Consent form load failed: [%d] %s" % [error.error_code, error.message])
	_start_admob_after_consent()

func _on_consent_form_dismissed(error: FormError):
	if error:
		print("[AdMob/UMP] Consent form dismissed with error: [%d] %s" % [error.error_code, error.message])
	else:
		var status: int = UserMessagingPlatform.consent_information.get_consent_status()
		print("[AdMob/UMP] Consent form dismissed — status: %d" % status)
	_start_admob_after_consent()

func _start_admob_after_consent():
	print("[AdMob] Initializing MobileAds after consent flow...")
	
	# Configure ad content rating and child-directed treatment BEFORE init
	var request_config := RequestConfiguration.new()
	request_config.max_ad_content_rating = RequestConfiguration.MAX_AD_CONTENT_RATING_G
	request_config.tag_for_child_directed_treatment = RequestConfiguration.TagForChildDirectedTreatment.TRUE
	request_config.tag_for_under_age_of_consent = RequestConfiguration.TagForUnderAgeOfConsent.TRUE
	MobileAds.set_request_configuration(request_config)
	print("[AdMob] RequestConfiguration set: rating=G, child_directed=TRUE, under_age=TRUE")
	
	var listener = OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(status: InitializationStatus):
		_admob_available = true
		print("[AdMob] Initialized OK — loading ads...")
		await get_tree().create_timer(1.0).timeout
		_preload_rewarded_ad()
		_init_banner_ad()
		_preload_interstitial_ad()
	MobileAds.initialize(listener)

func _preload_rewarded_ad():
	if not _admob_available or DEBUG_FORCE_FAKE_ADS: return
	var callback = RewardedAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: RewardedAd):
		print("[AdMob] Rewarded ad loaded OK")
		_rewarded_ad = ad
	callback.on_ad_failed_to_load = func(err):
		print("[AdMob] Rewarded ad failed: ", err)
		_rewarded_ad = null
		notif.queue_notification("Ad failed to load", Color(1.0, 0.5, 0.5), 2.0)
	RewardedAdLoader.new().load(REWARDED_AD_UNIT_ID, AdRequest.new(), callback)

func _init_banner_ad():
	if not _admob_available or DEBUG_FORCE_FAKE_ADS: return
	if BANNER_AD_UNIT_ID.is_empty():
		print("[AdMob] Banner unit ID not set — skipping banner")
		return
	_banner_ad = AdView.new(BANNER_AD_UNIT_ID, AdSize.BANNER, AdPosition.Values.BOTTOM)
	var listener := AdListener.new()
	listener.on_ad_loaded = func():
		print("[AdMob] Banner loaded OK")
		# Pokaż banner tylko jeśli jesteśmy na victory screenie
		if victory_ui and victory_ui.visible:
			_banner_ad.show()
	listener.on_ad_failed_to_load = func(err):
		print("[AdMob] Banner failed: ", err)
	_banner_ad.ad_listener = listener
	_banner_ad.load_ad(AdRequest.new())
	_banner_ad.hide()

func _preload_interstitial_ad():
	if not _admob_available or DEBUG_FORCE_FAKE_ADS: return
	if INTERSTITIAL_AD_UNIT_ID.is_empty():
		print("[AdMob] Interstitial unit ID not set — skipping interstitial")
		return
	if _interstitial_ad != null:
		return

	var load_callback := InterstitialAdLoadCallback.new()
	load_callback.on_ad_loaded = func(ad: InterstitialAd):
		print("[AdMob] Interstitial loaded OK")
		var content_callback := FullScreenContentCallback.new()
		content_callback.on_ad_dismissed_full_screen_content = func():
			if _interstitial_ad:
				_interstitial_ad.destroy()
				_interstitial_ad = null
			_preload_interstitial_ad()
		content_callback.on_ad_failed_to_show_full_screen_content = func(err: AdError):
			print("[AdMob] Interstitial show failed: ", err)
			if _interstitial_ad:
				_interstitial_ad.destroy()
				_interstitial_ad = null
			_preload_interstitial_ad()
		ad.full_screen_content_callback = content_callback
		_interstitial_ad = ad
	load_callback.on_ad_failed_to_load = func(err: LoadAdError):
		print("[AdMob] Interstitial load failed: ", err)
		_interstitial_ad = null

	InterstitialAdLoader.new().load(INTERSTITIAL_AD_UNIT_ID, AdRequest.new(), load_callback)

func _maybe_show_interstitial_after_kill():
	if DEBUG_FORCE_FAKE_ADS or not _admob_available:
		return
	if _interstitial_ad == null:
		_preload_interstitial_ad()
		return

	_kills_since_interstitial += 1
	if _kills_since_interstitial < INTERSTITIAL_FREQUENCY:
		return

	_kills_since_interstitial = 0
	print("[AdMob] Showing interstitial after %d kills" % INTERSTITIAL_FREQUENCY)
	_interstitial_ad.show()

func _on_watch_ad_pressed():
	print("[AdMob] WatchAd pressed: hp=%d/%d uses=%d available=%s rewarded=%s" % [player.current_hp, player.max_hp, ad_uses_this_stage, str(_admob_available), str(_rewarded_ad != null)])
	if ad_uses_this_stage >= MAX_AD_PER_STAGE:
		vfx.spawn_floating_text("AD LIMIT REACHED", Color.ORANGE)
		print("[AdMob] WatchAd blocked: stage limit reached")
		return
	if player.current_hp >= player.max_hp:
		vfx.spawn_floating_text("ALREADY FULL HP", Color.ORANGE)
		print("[AdMob] WatchAd blocked: player already full HP")
		return

	if _admob_available and _rewarded_ad:
		print("[AdMob] WatchAd: showing rewarded")
		_show_real_ad()
	elif not _admob_available:
		print("[AdMob] WatchAd: AdMob unavailable — showing fake ad")
		_show_fake_ad()
	else:
		print("[AdMob] WatchAd: ad not loaded yet — showing fake ad fallback, preload triggered")
		_preload_rewarded_ad()
		_show_fake_ad()

func _grant_ad_reward():
	player.current_hp = player.max_hp
	player.health_changed.emit(player.current_hp, player.max_hp)
	ad_uses_this_stage += 1
	vfx.spawn_floating_text("FULL HEAL!", Color.SPRING_GREEN)
	vfx.vibrate(60)
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
		vfx.play_battle_fade_in()
	_rewarded_ad.show(reward_listener)

func _show_fake_ad():
	if not DEBUG_FORCE_FAKE_ADS:
		return

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
	for i in range(5):
		ad_tween.parallel().tween_callback(func(): status.text = "Reward in %ds..." % (5-i)).set_delay(float(i))
	
	# Final cleanup and reward
	ad_tween.tween_callback(func():
		_grant_ad_reward()
		var out_t = create_tween()
		out_t.tween_property(backdrop, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		out_t.tween_callback(backdrop.queue_free)
	)

func _tween_bar(bar: Range, target: float, duration: float = 0.2):
	if not bar: return
	var t = bar.create_tween()
	t.tween_property(bar, "value", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

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
		vfx.spawn_floating_text("POISON -%d" % player.poison_dps, Color.PURPLE)
		if player.current_hp <= 1:
			vfx.spawn_floating_text("DANGER!", Color.RED)

func _update_xp_label():
	if not xp_label:
		return
	xp_label.text = "%d / %d" % [player.xp, player.xp_required]
	if xp_bar:
		xp_bar.min_value = 0
		xp_bar.max_value = max(1, player.xp_required)
		_tween_bar(xp_bar, float(clamp(player.xp, 0, xp_bar.max_value)), 0.3)

# === MVP POLISH: Loot Summary ===
func _update_loot_summary():
	# Populate loot icon grid — TextureRect+Label per item, XP label-only, no raw text row
	if loot_summary_label:
		loot_summary_label.visible = false
		loot_summary_label.text = ""
	if loot_icons_grid:
		for child in loot_icons_grid.get_children():
			child.queue_free()
		# XP entry — label only, no icon
		var xp_lbl = Label.new()
		xp_lbl.text = "%s XP" % format_number(kill_xp)
		xp_lbl.add_theme_font_size_override("font_size", 11)
		xp_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
		var xp_ls = LabelSettings.new()
		xp_ls.outline_size = 2; xp_ls.outline_color = Color.BLACK
		xp_lbl.label_settings = xp_ls
		xp_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		loot_icons_grid.add_child(xp_lbl)
		# Icon entries: Gold, resource, potion
		var icon_entries: Array = [
			{"tex": _get_icon_texture("res://assets/icons/coin.png"), "count": kill_gold, "color": Color.GOLD},
		]
		if kill_resource != "" and kill_resource_amount > 0:
			icon_entries.append({"tex": _get_resource_icon(kill_resource), "count": kill_resource_amount, "color": Color.MEDIUM_PURPLE})
		if kill_potion:
			# Keep potion icon un-tinted so it matches the HUD button icon exactly.
			icon_entries.append({"tex": POTION_ICON_TEXTURE, "count": 1, "color": Color.SPRING_GREEN, "icon_modulate": Color.WHITE})
		for entry in icon_entries:
			var col = VBoxContainer.new()
			col.add_theme_constant_override("separation", 2)
			loot_icons_grid.add_child(col)
			if inventory_slot_scene:
				var slot = inventory_slot_scene.instantiate()
				col.add_child(slot)
				if slot.has_method("set_item"):
					slot.set_item(entry.tex, int(entry.count), Color.WHITE)
			else:
				var icon = TextureRect.new()
				icon.texture = entry.tex
				icon.custom_minimum_size = Vector2(40, 40)
				icon.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.modulate = Color.WHITE
				col.add_child(icon)
			var lbl = Label.new()
			lbl.text = format_number(entry.count)
			lbl.add_theme_font_size_override("font_size", 9)
			lbl.add_theme_color_override("font_color", entry.color)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var ls = LabelSettings.new()
			ls.outline_size = 2; ls.outline_color = Color.BLACK
			lbl.label_settings = ls
			col.add_child(lbl)
		# Animate grid fade-in
		loot_icons_grid.modulate = Color(1, 1, 1, 0)
		var gt = create_tween()
		gt.tween_property(loot_icons_grid, "modulate:a", 1.0, 0.35)
