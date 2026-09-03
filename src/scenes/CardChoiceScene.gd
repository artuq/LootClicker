extends Control

signal choice_completed

@onready var card_container = %CardContainer
@onready var dimmer: ColorRect = get_node_or_null("ColorRect")
@onready var title_label: Label = get_node_or_null("Label")
var upgrade_manager = UpgradeManager.new()
var player: PlayerStats
var selection_locked: bool = false
var _reroll_btn: Button = null
var _reroll_in_progress: bool = false
var _rerolls_remaining: int = 1
var _is_spinning: bool = false
var tutorial_mode: bool = false
var forced_upgrade_id: String = ""
var tutorial_guide_text: String = "Choose your reward!"
var tutorial_guide_label: Label = null
var tutorial_hand_icon: TextureRect = null
var tutorial_hand_tween: Tween = null
var card_by_id: Dictionary = {}

const TITLE_HOLD_TIME := 1.0
const CARD_STAGGER_STEP := 0.08
const CARD_ENTRY_OFFSET_Y := 44.0
var TUTORIAL_HAND_TEXTURE: Texture2D = (
	load("res://assets/ui/tutorial/hand_cursor.png")
	if ResourceLoader.exists("res://assets/ui/tutorial/hand_cursor.png")
	else null
)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	if dimmer:
		dimmer.mouse_filter = Control.MOUSE_FILTER_STOP

func setup(p_ref: PlayerStats, cfg: Dictionary = {}):
	player = p_ref
	if not player:
		print("ERROR: CardChoiceScene.setup() - player is null!")
		queue_free()
		return

	tutorial_mode = bool(cfg.get("tutorial_mode", false))
	forced_upgrade_id = str(cfg.get("forced_upgrade_id", ""))
	tutorial_guide_text = str(cfg.get("guide_text", "Choose your reward!"))
		
	get_tree().paused = true # Stop combat
	selection_locked = false
	_rerolls_remaining = 1
	_is_spinning = false
	_reroll_in_progress = false
	card_by_id.clear()
	
	# Clear old cards
	for child in card_container.get_children():
		child.queue_free()
	
	# Roll 3 options
	var options = _build_options_with_tutorial()
	print("DEBUG: CardChoiceScene setup with %d options" % options.size())
	
	for opt in options:
		var card = create_card(opt)
		card_by_id[str(opt.id)] = card
		card.disabled = true
		card.modulate.a = 0.0
		card.scale = Vector2(0.8, 0.8)
		card_container.add_child(card)

	card_container.visible = false
	_setup_reroll_button()
	call_deferred("_play_level_up_sequence")

func _play_level_up_sequence():
	if not title_label:
		_reveal_cards()
		return

	var viewport_size := get_viewport_rect().size

	if dimmer:
		dimmer.color = Color(0, 0, 0, 0.0)

	title_label.text = "LEVEL UP!"
	title_label.add_theme_font_size_override("font_size", 46)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size = Vector2(320, 64)
	title_label.pivot_offset = title_label.size * 0.5
	title_label.modulate = Color(1, 1, 1, 0)
	title_label.scale = Vector2(0.45, 0.45)
	title_label.position = Vector2((viewport_size.x - title_label.size.x) * 0.5, (viewport_size.y - title_label.size.y) * 0.5)

	var intro_tween = create_tween()
	if dimmer:
		intro_tween.tween_property(dimmer, "color:a", 0.82, 0.2)
	intro_tween.parallel().tween_property(title_label, "modulate:a", 1.0, 0.18)
	intro_tween.parallel().tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(TITLE_HOLD_TIME).timeout

	var top_target := Vector2((viewport_size.x - title_label.size.x) * 0.5, 56)

	var move_tween = create_tween()
	move_tween.tween_property(title_label, "position", top_target, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.parallel().tween_property(title_label, "scale", Vector2(0.82, 0.82), 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await move_tween.finished
	_reveal_cards()

func _reveal_cards():
	card_container.visible = true
	var i := 0
	for card in card_container.get_children():
		if not (card is Button):
			continue
		var card_btn := card as Button
		var delay := float(i) * CARD_STAGGER_STEP
		var target_y := card_btn.position.y
		card_btn.position.y = target_y + CARD_ENTRY_OFFSET_Y
		var t = create_tween()
		t.tween_interval(delay)
		t.tween_property(card_btn, "modulate:a", 1.0, 0.16)
		t.parallel().tween_property(card_btn, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(card_btn, "position:y", target_y, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		card_btn.disabled = false
		i += 1

	if _reroll_btn and not tutorial_mode and _rerolls_remaining > 0:
		var bt = create_tween()
		bt.tween_interval(float(i) * CARD_STAGGER_STEP)
		bt.tween_property(_reroll_btn, "modulate:a", 1.0, 0.2)
		_reroll_btn.disabled = false

	if tutorial_mode:
		_apply_tutorial_card_lock()

func _build_options_with_tutorial() -> Array:
	if not tutorial_mode or forced_upgrade_id == "":
		return upgrade_manager.get_random_options(3)

	var forced_card: Dictionary = {}
	for opt in upgrade_manager.available_cards:
		if str(opt.get("id", "")) == forced_upgrade_id:
			forced_card = opt
			break
	if forced_card.is_empty():
		return upgrade_manager.get_random_options(3)

	var pool: Array = []
	for opt in upgrade_manager.available_cards:
		if str(opt.get("id", "")) != forced_upgrade_id:
			pool.append(opt)
	pool.shuffle()

	var options: Array = [forced_card]
	while options.size() < 3 and pool.size() > 0:
		options.append(pool.pop_front())
	options.shuffle()
	return options

func _apply_tutorial_card_lock():
	var forced_button: Button = card_by_id.get(forced_upgrade_id, null)
	for child in card_container.get_children():
		if not (child is Button):
			continue
		var card_btn := child as Button
		if card_btn == forced_button:
			card_btn.disabled = false
			card_btn.modulate = Color(1, 1, 1, 1)
		else:
			card_btn.disabled = true
			card_btn.modulate = Color(0.45, 0.45, 0.45, 0.65)

	if forced_button:
		_show_tutorial_hint_for_card(forced_button)

func _show_tutorial_hint_for_card(target_card: Button):
	if tutorial_guide_label and is_instance_valid(tutorial_guide_label):
		tutorial_guide_label.queue_free()
	if tutorial_hand_icon and is_instance_valid(tutorial_hand_icon):
		tutorial_hand_icon.queue_free()
	if tutorial_hand_tween:
		tutorial_hand_tween.kill()

	tutorial_guide_label = Label.new()
	tutorial_guide_label.text = tutorial_guide_text
	tutorial_guide_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_guide_label.add_theme_font_size_override("font_size", 16)
	tutorial_guide_label.add_theme_color_override("font_color", Color.WHITE)
	var ls = LabelSettings.new()
	ls.outline_size = 2
	ls.outline_color = Color(0, 0, 0, 0.6)
	tutorial_guide_label.label_settings = ls
	var bubble_bg = StyleBoxFlat.new()
	bubble_bg.bg_color = Color(0.08, 0.06, 0.18, 0.88)
	bubble_bg.corner_radius_top_left = 12
	bubble_bg.corner_radius_top_right = 12
	bubble_bg.corner_radius_bottom_left = 12
	bubble_bg.corner_radius_bottom_right = 12
	bubble_bg.content_margin_left = 14
	bubble_bg.content_margin_right = 14
	bubble_bg.content_margin_top = 10
	bubble_bg.content_margin_bottom = 10
	bubble_bg.border_width_left = 2
	bubble_bg.border_width_right = 2
	bubble_bg.border_width_top = 2
	bubble_bg.border_width_bottom = 2
	bubble_bg.border_color = Color(0.55, 0.45, 0.9, 0.7)
	tutorial_guide_label.add_theme_stylebox_override("normal", bubble_bg)
	add_child(tutorial_guide_label)

	tutorial_hand_icon = TextureRect.new()
	tutorial_hand_icon.texture = TUTORIAL_HAND_TEXTURE
	tutorial_hand_icon.custom_minimum_size = Vector2(52, 52)
	tutorial_hand_icon.size = Vector2(52, 52)
	tutorial_hand_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tutorial_hand_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(tutorial_hand_icon)

	var card_pos := target_card.global_position
	tutorial_guide_label.position = _clamp_to_viewport(card_pos + Vector2(-58, -72), tutorial_guide_label.custom_minimum_size)
	var hand_start := _clamp_to_viewport(card_pos + Vector2(34, 18), tutorial_hand_icon.custom_minimum_size)
	tutorial_hand_icon.position = hand_start
	tutorial_hand_tween = create_tween().set_loops()
	tutorial_hand_tween.tween_property(tutorial_hand_icon, "position:y", hand_start.y + 6.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tutorial_hand_tween.parallel().tween_property(tutorial_hand_icon, "scale", Vector2(0.92, 0.92), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tutorial_hand_tween.tween_property(tutorial_hand_icon, "position:y", hand_start.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tutorial_hand_tween.parallel().tween_property(tutorial_hand_icon, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _clamp_to_viewport(pos: Vector2, node_size: Vector2) -> Vector2:
	var view := get_viewport_rect().size
	var margin := 12.0
	return Vector2(
		clampf(pos.x, margin, max(margin, view.x - node_size.x - margin)),
		clampf(pos.y, margin, max(margin, view.y - node_size.y - margin))
	)

func create_card_content(opt: Dictionary) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var is_cursed = opt.get("cursed", false)

	# Top tag slot (always present to keep all cards aligned)
	var curse_tag = Label.new()
	curse_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	curse_tag.add_theme_font_size_override("font_size", 8)
	curse_tag.custom_minimum_size = Vector2(0, 10)
	if is_cursed:
		curse_tag.text = "CURSED"
		curse_tag.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	else:
		curse_tag.text = " "
		curse_tag.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	vbox.add_child(curse_tag)

	# Ikona AI
	var tex_rect = TextureRect.new()
	var tex = load(opt.icon)
	if tex:
		tex_rect.texture = tex
	tex_rect.custom_minimum_size = Vector2(70, 70)
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vbox.add_child(tex_rect)

	# Tekst - nazwa
	var name_lbl = Label.new()
	name_lbl.text = opt.get("flavor_name", opt.name).to_upper()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 11)
	if is_cursed:
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.65, 0.5))
	vbox.add_child(name_lbl)

	# Tekst - opis klimatyczny
	var lbl = Label.new()
	lbl.text = opt.get("flavor_desc", opt.desc)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.custom_minimum_size = Vector2(100, 0)
	lbl.add_theme_font_size_override("font_size", 11)
	if is_cursed:
		var ls_curse = LabelSettings.new()
		ls_curse.font_size = 11  # MUST match non-cursed font_size — label_settings overrides theme overrides
		ls_curse.font_color = Color(1.0, 0.82, 0.78)
		ls_curse.outline_size = 2
		ls_curse.outline_color = Color(0.3, 0.0, 0.0, 0.9)
		lbl.label_settings = ls_curse
	vbox.add_child(lbl)

	# Tekst - statystyki w nawiasie
	var stat_lbl = Label.new()
	stat_lbl.text = opt.get("stat_short", opt.desc)
	stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	stat_lbl.add_theme_font_size_override("font_size", 10)
	stat_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	if is_cursed:
		var ls_stat = LabelSettings.new()
		ls_stat.font_size = 10  # MUST match non-cursed font_size
		ls_stat.font_color = Color(1.0, 0.5, 0.45)
		ls_stat.outline_size = 2
		ls_stat.outline_color = Color(0.2, 0.0, 0.0, 0.9)
		stat_lbl.label_settings = ls_stat
	vbox.add_child(stat_lbl)

	return vbox

func create_card(opt: Dictionary) -> Button:
	# Use Button with all styleboxes cleared to prevent default gray background on Android
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(118, 220)
	btn.clip_contents = true
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.focus_mode = Control.FOCUS_NONE

	# All cards get a clean transparent background
	btn.flat = true
	var empty_style = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.add_theme_stylebox_override("disabled", empty_style)

	var content = create_card_content(opt)
	btn.add_child(content)

	btn.pressed.connect(_on_card_selected.bind(opt, btn))

	# Add juice
	btn.pivot_offset = btn.custom_minimum_size / 2
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)

	return btn

func _on_card_selected(opt: Dictionary, selected_button: Button):
	if selection_locked:
		return
	if tutorial_mode and forced_upgrade_id != "" and str(opt.id) != forced_upgrade_id:
		return
	selection_locked = true

	if not player:
		print("ERROR: CardChoiceScene._on_card_selected() - player is null!")
		get_tree().paused = false
		queue_free()
		return

	for card in card_container.get_children():
		if card is Button:
			(card as Button).disabled = true
	
	print("DEBUG: Card selected - %s" % opt.id)

	# Selected card gets bounce + flash while rejected cards fade and shrink away.
	var react_tween := create_tween()
	react_tween.tween_property(selected_button, "scale", Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	react_tween.parallel().tween_property(selected_button, "modulate", Color(1.22, 1.22, 1.12, 1.0), 0.08)
	react_tween.tween_property(selected_button, "modulate", Color.WHITE, 0.08)
	react_tween.parallel().tween_property(selected_button, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	for card in card_container.get_children():
		if card == selected_button or not (card is Button):
			continue
		var out_tween = create_tween()
		out_tween.tween_property(card, "modulate:a", 0.0, 0.18)
		out_tween.parallel().tween_property(card, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	if _reroll_btn:
		_reroll_btn.disabled = true
		var rt = create_tween()
		rt.tween_property(_reroll_btn, "modulate:a", 0.0, 0.15)

	upgrade_manager.apply_upgrade(player, opt.id)
	await react_tween.finished

	# Send selected card downward towards HUD/inventory direction.
	var view := get_viewport_rect().size
	var target := selected_button.position + Vector2((view.x * 0.5 - selected_button.position.x) * 0.12, 220)
	var exit_tween := create_tween().set_parallel(true)
	exit_tween.tween_property(selected_button, "position", target, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(selected_button, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(selected_button, "modulate:a", 0.0, 0.16)
	await exit_tween.finished

	var close_tween = create_tween()
	close_tween.tween_property(self, "modulate:a", 0.0, 0.14)
	await close_tween.finished

	if tutorial_hand_tween:
		tutorial_hand_tween.kill()
	if tutorial_guide_label and is_instance_valid(tutorial_guide_label):
		tutorial_guide_label.queue_free()
	if tutorial_hand_icon and is_instance_valid(tutorial_hand_icon):
		tutorial_hand_icon.queue_free()

	choice_completed.emit()
	get_tree().paused = false
	queue_free()


func _setup_reroll_button():
	if _reroll_btn and is_instance_valid(_reroll_btn):
		return

	var platform_mgr = get_node_or_null("/root/PlatformManager")
	var is_free: bool = platform_mgr != null and platform_mgr.has_ad_free_entitlement()

	_reroll_btn = Button.new()
	_reroll_btn.name = "RerollButton"
	_reroll_btn.text = "🎲 FREE REROLL" if is_free else "🎲 REROLL (AD)"
	_reroll_btn.custom_minimum_size = Vector2(230, 48)
	_reroll_btn.focus_mode = Control.FOCUS_NONE

	# StyleBoxTexture matching 1:1 Art Bible Game_button_normal.png
	var btn_normal_tex = load("res://assets/New sprites/Game_button_normal.png")
	var btn_pressed_tex = load("res://assets/New sprites/GAME_BUTTON_PRESSED.png")

	var normal_sb = StyleBoxTexture.new()
	if btn_normal_tex:
		normal_sb.texture = btn_normal_tex
		normal_sb.texture_margin_left = 20.0
		normal_sb.texture_margin_top = 8.0
		normal_sb.texture_margin_right = 20.0
		normal_sb.texture_margin_bottom = 8.0

	var pressed_sb = StyleBoxTexture.new()
	if btn_pressed_tex:
		pressed_sb.texture = btn_pressed_tex
		pressed_sb.texture_margin_left = 20.0
		pressed_sb.texture_margin_top = 8.0
		pressed_sb.texture_margin_right = 20.0
		pressed_sb.texture_margin_bottom = 8.0

	_reroll_btn.add_theme_stylebox_override("normal", normal_sb)
	_reroll_btn.add_theme_stylebox_override("hover", normal_sb)
	_reroll_btn.add_theme_stylebox_override("focus", normal_sb)
	_reroll_btn.add_theme_stylebox_override("pressed", pressed_sb)

	# Colors & font size (Gold for Remove Ads owners, Green for AdMob)
	if is_free:
		_reroll_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4, 1.0))
		_reroll_btn.add_theme_color_override("font_pressed_color", Color(0.85, 0.7, 0.2, 1.0))
		_reroll_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.6, 1.0))
	else:
		_reroll_btn.add_theme_color_override("font_color", Color(0.6, 0.95, 0.6, 1.0))
		_reroll_btn.add_theme_color_override("font_pressed_color", Color(0.4, 0.8, 0.4, 1.0))
		_reroll_btn.add_theme_color_override("font_hover_color", Color(0.7, 1.0, 0.7, 1.0))

	_reroll_btn.add_theme_font_size_override("font_size", 13)

	# Position anchored at bottom center
	_reroll_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_reroll_btn.offset_left = -115.0
	_reroll_btn.offset_right = 115.0
	_reroll_btn.offset_top = -110.0
	_reroll_btn.offset_bottom = -62.0
	_reroll_btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_reroll_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN

	_reroll_btn.modulate.a = 0.0
	_reroll_btn.disabled = true
	_reroll_btn.pressed.connect(_on_reroll_pressed)

	add_child(_reroll_btn)


func _on_reroll_pressed():
	if selection_locked or _reroll_in_progress or _is_spinning or _rerolls_remaining <= 0:
		return
	_reroll_in_progress = true
	_rerolls_remaining -= 1

	var platform_mgr = get_node_or_null("/root/PlatformManager")
	var is_free: bool = platform_mgr == null or platform_mgr.has_ad_free_entitlement()

	if _reroll_btn:
		_reroll_btn.disabled = true
		if not is_free:
			_reroll_btn.text = "⏳ LOADING AD..."
		else:
			var bt = create_tween()
			bt.tween_property(_reroll_btn, "modulate:a", 0.0, 0.2)

	if not is_free:
		platform_mgr.request_rewarded_ad(
			"card_reroll",
			Callable(self, "_on_reroll_ad_success"),
			Callable(self, "_on_reroll_ad_failed"),
			self
		)
	else:
		_on_reroll_ad_success()


func _on_reroll_ad_success():
	print("[CardChoiceScene] Reroll triggered! Starting slot machine reel...")
	if _reroll_btn:
		var bt = create_tween()
		bt.tween_property(_reroll_btn, "modulate:a", 0.0, 0.2)
	# Small delay so player is 100% focused on the game screen after closing the ad
	await get_tree().create_timer(0.1).timeout
	_play_slot_machine_reroll()


func _play_slot_machine_reroll():
	selection_locked = true
	_is_spinning = true

	# 3 target winning cards
	var new_options = upgrade_manager.get_random_options(3)
	card_by_id.clear()

	# Pool of intermediate icons for spinning reels
	var reel_pool: Array = []
	reel_pool.append_array(upgrade_manager.available_cards)
	reel_pool.append_array(upgrade_manager.cursed_cards)
	reel_pool.shuffle()

	var card_buttons: Array = []
	for child in card_container.get_children():
		if child is Button:
			card_buttons.append(child)

	const ITEM_HEIGHT: float = 220.0
	const REEL_SPIN_ITEMS: int = 5
	var durations = [0.55, 0.80, 1.05]
	var audio = get_node_or_null("/root/AudioManager")

	# Rapid mechanical tick sound during spin
	var ticker_tween = create_tween().set_loops(12)
	ticker_tween.tween_callback(func():
		if _is_spinning and audio and is_instance_valid(self):
			if audio.has_method("play_sound"):
				audio.play_sound("ui_click", randf_range(1.3, 1.7))
			elif audio.has_method("play_ui_click_sound"):
				audio.play_ui_click_sound()
	)
	ticker_tween.tween_interval(0.08)

	for col_idx in range(min(card_buttons.size(), 3)):
		var btn: Button = card_buttons[col_idx]
		btn.disabled = true
		btn.clip_contents = true
		btn.custom_minimum_size = Vector2(118, ITEM_HEIGHT)

		# Disconnect previous pressed connections
		for conn in btn.pressed.get_connections():
			btn.pressed.disconnect(conn.callable)

		var old_children = btn.get_children()

		# Build spinning reel strip
		var strip = VBoxContainer.new()
		strip.alignment = BoxContainer.ALIGNMENT_BEGIN
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_theme_constant_override("separation", 0)
		strip.custom_minimum_size = Vector2(118, 0)
		strip.position = Vector2.ZERO

		# 1. Slot 0: Old card content
		var slot_0 = Control.new()
		slot_0.custom_minimum_size = Vector2(118, ITEM_HEIGHT)
		slot_0.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if old_children.size() > 0:
			var old_c = old_children[0]
			btn.remove_child(old_c)
			slot_0.add_child(old_c)
		strip.add_child(slot_0)

		# 2. Intermediate spinning slots (5 random cards)
		for k in range(REEL_SPIN_ITEMS):
			var rand_opt = reel_pool[(col_idx * 3 + k) % reel_pool.size()]
			var rand_slot = Control.new()
			rand_slot.custom_minimum_size = Vector2(118, ITEM_HEIGHT)
			rand_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rand_slot.add_child(create_card_content(rand_opt))
			strip.add_child(rand_slot)

		# 3. Final target slot
		var target_opt = new_options[col_idx]
		var target_slot = Control.new()
		target_slot.custom_minimum_size = Vector2(118, ITEM_HEIGHT)
		target_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var target_content = create_card_content(target_opt)
		target_slot.add_child(target_content)
		strip.add_child(target_slot)

		btn.add_child(strip)

		var target_scroll_y: float = float(REEL_SPIN_ITEMS + 1) * ITEM_HEIGHT
		var col_duration: float = durations[col_idx]

		var reel_tween = create_tween()
		reel_tween.tween_property(strip, "position:y", -target_scroll_y, col_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		var this_col := col_idx
		var this_opt: Dictionary = target_opt
		var this_btn: Button = btn

		reel_tween.tween_callback(func():
			# Punch scale on stop
			var punch = create_tween()
			punch.tween_property(this_btn, "scale", Vector2(1.08, 1.08), 0.06)
			punch.tween_property(this_btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			# Sound effect on stop
			if audio:
				if this_col < 2:
					if audio.has_method("play_sound"):
						audio.play_sound("ui_click", 1.0 + float(this_col) * 0.25)
					elif audio.has_method("play_ui_click_sound"):
						audio.play_ui_click_sound()
				else:
					if audio.has_method("play_sound"):
						audio.play_sound("coin", 1.05)
					elif audio.has_method("play_coin_sound"):
						audio.play_coin_sound()

			# Register card option and hook up selection
			card_by_id[str(this_opt.id)] = this_btn
			this_btn.pressed.connect(_on_card_selected.bind(this_opt, this_btn))
		)

	# Wait for the longest reel (col 2) to finish + settle bounce
	await get_tree().create_timer(durations[2] + 0.2).timeout

	if ticker_tween and ticker_tween.is_valid():
		ticker_tween.kill()

	# Re-enable cards for selection
	for child in card_container.get_children():
		if child is Button:
			(child as Button).disabled = false

	selection_locked = false
	_is_spinning = false
	_reroll_in_progress = false


func _on_reroll_ad_failed():
	print("[CardChoiceScene] Reroll ad failed or closed without reward.")
	_reroll_in_progress = false
	_rerolls_remaining += 1
	if _reroll_btn and not selection_locked:
		var platform_mgr = get_node_or_null("/root/PlatformManager")
		var is_free: bool = platform_mgr != null and platform_mgr.has_ad_free_entitlement()
		_reroll_btn.text = "🎲 FREE REROLL" if is_free else "🎲 REROLL (AD)"
		_reroll_btn.disabled = false
		var bt = create_tween()
		bt.tween_property(_reroll_btn, "modulate:a", 1.0, 0.15)
