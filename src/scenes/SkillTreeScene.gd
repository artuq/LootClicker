extends Control

@onready var points_label = %PointsLabel
@onready var _tree_panel = %TreePanel
@onready var _connections = %Connections
@onready var _tooltip_bg = %TooltipBG
@onready var _tooltip_label = %TooltipLabel
var player: PlayerStats
var _skill_map: Dictionary = {}   # skill_id → SkillNode
var _line_map: Dictionary = {}    # "from->to" -> ColorRect
var _selected_node: SkillNode = null

# Popup layer (CanvasLayer renders above everything)
var _popup_layer: CanvasLayer = null
var _popup_overlay: ColorRect = null
var _popup_panel: PanelContainer = null
var _tip_name_label: Label = null
var _tip_desc_label: Label = null
var _tip_level_label: Label = null
var _tip_cost_label: Label = null
var _upgrade_btn: Button = null
var _popup_tween: Tween = null

const _CONNECTIONS := {
	"str": ["greed"],
	"hp": ["crit"],
	"greed": ["speed"],
	"crit": ["def"],
}
const _LINE_LOCKED := Color(0.55, 0.55, 0.75, 0.58)
const _LINE_UNLOCKED := Color(0.2, 0.92, 0.45, 1.0)
const _LINE_MAX := Color(1.0, 0.9, 0.35, 1.0)

func setup(p_ref: PlayerStats):
	player = p_ref
	_apply_mobile_label_readability()
	_build_skill_popup()

	# Connect refresh
	if not player.skills_updated.is_connected(update_ui):
		player.skills_updated.connect(update_ui)
	if not player.resources_updated.is_connected(update_ui):
		player.resources_updated.connect(update_ui)

	# Initialize all nodes + build map
	_skill_map.clear()
	for node in %TreeLayout.get_children():
		if node is SkillNode:
			node.setup(player)
			_skill_map[node.skill_id] = node
			if not node.pressed.is_connected(_on_node_pressed.bind(node)):
				node.pressed.connect(_on_node_pressed.bind(node))

	_setup_line_map()
	_update_connection_colors()

	if has_node("BackButton"):
		_add_button_juice($BackButton)

	# Hide old tooltip nodes (kept in scene for backwards compat)
	if _tooltip_bg:
		_tooltip_bg.visible = false

	update_ui()
	animate_open()

func _apply_mobile_label_readability():
	var points_ls := LabelSettings.new()
	points_ls.outline_size = 3
	points_ls.outline_color = Color(0, 0, 0, 0.85)
	points_label.label_settings = points_ls
	points_label.add_theme_font_size_override("font_size", 17)

func _build_skill_popup():
	# CanvasLayer at layer 200 — always above everything (bottom nav is 110)
	_popup_layer = CanvasLayer.new()
	_popup_layer.layer = 200
	_popup_layer.visible = false
	add_child(_popup_layer)

	# Semi-transparent overlay — tap to close popup
	_popup_overlay = ColorRect.new()
	_popup_overlay.color = Color(0, 0, 0, 0.55)
	_popup_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_popup_overlay.gui_input.connect(_on_overlay_input)
	_popup_layer.add_child(_popup_overlay)

	# Center wrapper — positions popup in the center of the screen
	var center_wrap := CenterContainer.new()
	center_wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup_layer.add_child(center_wrap)

	# Popup panel
	_popup_panel = PanelContainer.new()
	_popup_panel.name = "SkillPopup"
	_popup_panel.custom_minimum_size = Vector2(280, 180)
	_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.08, 0.06, 0.14, 0.97)
	ps.set_corner_radius_all(12)
	ps.set_border_width_all(3)
	ps.border_color = Color(0.5, 0.42, 0.65, 0.95)
	ps.content_margin_left = 16
	ps.content_margin_top = 14
	ps.content_margin_right = 16
	ps.content_margin_bottom = 14
	ps.shadow_color = Color(0, 0, 0, 0.5)
	ps.shadow_size = 8
	_popup_panel.add_theme_stylebox_override("panel", ps)
	center_wrap.add_child(_popup_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_popup_panel.add_child(vbox)

	# Skill name
	_tip_name_label = Label.new()
	_tip_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_name_label.add_theme_font_size_override("font_size", 18)
	_tip_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	var name_ls := LabelSettings.new()
	name_ls.outline_size = 3
	name_ls.outline_color = Color(0, 0, 0, 0.85)
	_tip_name_label.label_settings = name_ls
	vbox.add_child(_tip_name_label)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_stylebox_override("separator", StyleBoxLine.new())
	vbox.add_child(sep)

	# Description
	_tip_desc_label = Label.new()
	_tip_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_desc_label.add_theme_font_size_override("font_size", 13)
	_tip_desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	_tip_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_tip_desc_label)

	# Level
	_tip_level_label = Label.new()
	_tip_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_level_label.add_theme_font_size_override("font_size", 13)
	_tip_level_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	vbox.add_child(_tip_level_label)

	# Cost
	_tip_cost_label = Label.new()
	_tip_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_cost_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_tip_cost_label)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer)

	# BUY button — big, centered
	_upgrade_btn = Button.new()
	_upgrade_btn.text = "BUY"
	_upgrade_btn.custom_minimum_size = Vector2(200, 52)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.55, 0.3, 1.0)
	btn_style.set_corner_radius_all(8)
	btn_style.content_margin_left = 12
	btn_style.content_margin_right = 12
	btn_style.content_margin_top = 10
	btn_style.content_margin_bottom = 10
	_upgrade_btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover: StyleBoxFlat = btn_style.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.25, 0.65, 0.35, 1.0)
	_upgrade_btn.add_theme_stylebox_override("hover", btn_hover)
	var btn_pressed_style: StyleBoxFlat = btn_style.duplicate() as StyleBoxFlat
	btn_pressed_style.bg_color = Color(0.15, 0.45, 0.25, 1.0)
	_upgrade_btn.add_theme_stylebox_override("pressed", btn_pressed_style)
	var btn_disabled: StyleBoxFlat = btn_style.duplicate() as StyleBoxFlat
	btn_disabled.bg_color = Color(0.25, 0.25, 0.25, 0.7)
	_upgrade_btn.add_theme_stylebox_override("disabled", btn_disabled)
	_upgrade_btn.add_theme_font_size_override("font_size", 16)
	_upgrade_btn.add_theme_color_override("font_color", Color.WHITE)
	_upgrade_btn.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6))
	_upgrade_btn.pressed.connect(_on_upgrade_btn_pressed)
	_add_button_juice(_upgrade_btn)
	vbox.add_child(_upgrade_btn)

func _on_overlay_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		_close_popup()

func _add_button_juice(btn: Button):
	btn.pivot_offset = btn.size / 2
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.05)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

func animate_open():
	# Set pivot point to center for nice scaling
	pivot_offset = size / 2
	scale = Vector2.ZERO
	modulate.a = 0

	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func update_ui():
	if player == null: return

	points_label.text = "Gold: %d | Bandages: %d, Venom: %d, Shards: %d" % [
		player.gold,
		player.resources["bandages"],
		player.resources["venom"],
		player.resources["relic_shards"]
	]

	for node in %TreeLayout.get_children():
		if node is SkillNode:
			node.update_state()

	_update_connection_colors()

func _setup_line_map():
	_line_map = {
		"str->greed": %Line_STR_to_GREED,
		"hp->crit": %Line_HP_to_CRIT,
		"greed->speed": %Line_GREED_to_SPEED,
		"crit->def": %Line_CRIT_to_DEF,
	}

func _update_connection_colors():
	for from_id in _CONNECTIONS.keys():
		for to_id in _CONNECTIONS[from_id]:
			var key := "%s->%s" % [from_id, to_id]
			var rect: ColorRect = _line_map.get(key)
			if rect:
				rect.color = _line_color_for_source(from_id)

func _line_color_for_source(skill_id: String) -> Color:
	var lvl := _get_skill_level(skill_id)
	var n: SkillNode = _skill_map.get(skill_id)
	if n != null and lvl >= n.max_level:
		return _LINE_MAX
	if lvl > 0:
		return _LINE_UNLOCKED
	return _LINE_LOCKED

func _get_skill_level(id: String) -> int:
	match id:
		"str":
			return player.str_lvl
		"hp":
			return int((player.max_hp - 100) / 20.0)
		"greed":
			return player.greed_lvl
		"crit":
			return player.crit_lvl
		"speed":
			return player.speed_lvl
		"def":
			return player.def_lvl
		_:
			return 0

func _on_node_pressed(node: SkillNode):
	if _selected_node == node:
		_deselect()
	else:
		_deselect_silent()
		_selected_node = node
		node.set_selected(true)
		_open_popup(node)

func _on_upgrade_btn_pressed():
	if _selected_node:
		_do_purchase(_selected_node)

func _update_popup_content(node: SkillNode):
	var skill_name := node._skill_display_name()
	var desc := node._skill_description()
	var lvl = node._get_player_skill_lvl()
	var cost = player.get_skill_cost(node.skill_id)

	_tip_name_label.text = skill_name
	_tip_desc_label.text = desc
	_tip_level_label.text = "Lv %d / %d" % [lvl, node.max_level]

	if not node._req_met:
		_tip_cost_label.text = "⚠ Needs %s Lv.%d" % [node._req_display_name(node.requirement_skill), node.requirement_level]
		_tip_cost_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
		_upgrade_btn.disabled = true
		_upgrade_btn.text = "LOCKED"
	elif lvl >= node.max_level:
		_tip_cost_label.text = "MAX LEVEL"
		_tip_cost_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
		_upgrade_btn.disabled = true
		_upgrade_btn.text = "MAX"
	else:
		_tip_cost_label.text = "Cost: %d %s" % [cost, node._get_resource_display_name()]
		var can_afford := node._can_afford
		_tip_cost_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.55) if can_afford else Color(1.0, 0.5, 0.3))
		_upgrade_btn.disabled = not can_afford
		_upgrade_btn.text = "BUY"

func _open_popup(node: SkillNode):
	if not _popup_layer or not _popup_panel:
		return
	_update_popup_content(node)
	_popup_layer.visible = true
	_popup_overlay.modulate.a = 0.0
	_popup_panel.scale = Vector2.ZERO
	_popup_panel.pivot_offset = _popup_panel.size * 0.5
	if _popup_tween:
		_popup_tween.kill()
	_popup_tween = create_tween().set_parallel(true)
	_popup_tween.tween_property(_popup_overlay, "modulate:a", 1.0, 0.15)
	_popup_tween.tween_property(_popup_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_popup():
	if not _popup_layer or not _popup_layer.visible:
		return
	_deselect_silent()
	if _popup_tween:
		_popup_tween.kill()
	_popup_tween = create_tween().set_parallel(true)
	_popup_tween.tween_property(_popup_panel, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_popup_tween.tween_property(_popup_overlay, "modulate:a", 0.0, 0.15)
	_popup_tween.finished.connect(func(): _popup_layer.visible = false)

func _deselect_silent():
	if _selected_node != null:
		_selected_node.set_selected(false)
		_selected_node = null

func _deselect():
	_deselect_silent()
	_close_popup()

func _do_purchase(node: SkillNode):
	if not node._req_met:
		_play_error()
		return
	var cost = player.get_skill_cost(node.skill_id)

	if node.currency_type == "gold":
		if player.gold >= cost:
			player.gold -= cost
			_apply_skill(node.skill_id)
			_play_purchase_feedback(node)
			player.gold_changed.emit(player.gold)
			_update_popup_content(node)
		else:
			_play_error()
	else:
		var res_id = node._get_res_id()
		if player.resources[res_id] >= cost:
			player.add_resource(res_id, -cost)
			_apply_skill(node.skill_id)
			_play_purchase_feedback(node)
			_update_popup_content(node)
		else:
			_play_error()

func _play_purchase_feedback(node: SkillNode):
	if node == null:
		return
	var base_mod: Color = node.modulate
	var t: Tween = create_tween()
	t.tween_property(node, "scale", Vector2(1.16, 1.16), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(node, "modulate", Color(1.2, 1.2, 1.12, 1.0), 0.08)
	t.tween_property(node, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(node, "modulate", base_mod, 0.12)

func _apply_skill(id: String):
	match id:
		"str": player.str_lvl += 1
		"crit": player.crit_lvl += 1
		"greed": player.greed_lvl += 1
		"speed": player.speed_lvl += 1
		"def": player.def_lvl += 1
		"hp":
			player.max_hp += 20
			player.current_hp = player.max_hp
			player.health_changed.emit(player.current_hp, player.max_hp)
	player.skills_updated.emit()

func _play_error():
	if get_node_or_null("/root/AudioManager"):
		get_node("/root/AudioManager").play_error_sound()

func _on_back_button_pressed():
	_deselect_silent()
	if _popup_layer:
		_popup_layer.visible = false
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		get_tree().paused = false
		queue_free()
	)
