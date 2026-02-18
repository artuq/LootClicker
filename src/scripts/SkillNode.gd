extends Button
class_name SkillNode

@export var skill_id: String = "str"
@export var currency_type: String = "resource" # "gold" lub "resource"
@export var max_level: int = 50
@export var requirement_skill: String = ""
@export var requirement_level: int = 0
@export var icon_texture: Texture2D

var player: PlayerStats
var _name_label: Label
var _desc_label: Label
var _req_label: Label

# ── theme colours ────────────────────────────────────────────────────
const _BG_NORMAL   := Color(0.12, 0.12, 0.18, 0.92)
const _BG_HOVER    := Color(0.20, 0.20, 0.28, 0.95)
const _BG_PRESSED  := Color(0.08, 0.08, 0.14, 0.95)
const _BG_DISABLED := Color(0.08, 0.08, 0.10, 0.75)
const _BORDER_DEF  := Color(0.55, 0.55, 0.65, 0.7)
const _BORDER_MAX  := Color(1.0, 0.84, 0.0, 1.0)
const _BORDER_LOCK := Color(0.3, 0.3, 0.35, 0.5)
const _BORDER_AVAIL := Color(0.3, 1.0, 0.5, 0.85)

func setup(p_ref: PlayerStats):
	player = p_ref
	if icon_texture:
		icon = icon_texture
		expand_icon = true

	clip_text = true
	_apply_circle_theme()
	_create_name_label()

	pivot_offset = size / 2
	if not button_down.is_connected(_on_button_down):
		button_down.connect(_on_button_down)
	if not button_up.is_connected(_on_button_up):
		button_up.connect(_on_button_up)

	update_state()

# ── circular StyleBoxFlat ────────────────────────────────────────────
func _apply_circle_theme():
	var r := int(size.x * 0.5)
	for state_name in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.corner_radius_top_left    = r
		sb.corner_radius_top_right   = r
		sb.corner_radius_bottom_left = r
		sb.corner_radius_bottom_right = r
		sb.border_width_left   = 2
		sb.border_width_right  = 2
		sb.border_width_top    = 2
		sb.border_width_bottom = 2
		match state_name:
			"normal":   sb.bg_color = _BG_NORMAL;  sb.border_color = _BORDER_DEF
			"hover":    sb.bg_color = _BG_HOVER;   sb.border_color = _BORDER_DEF
			"pressed":  sb.bg_color = _BG_PRESSED;  sb.border_color = _BORDER_DEF
			"disabled": sb.bg_color = _BG_DISABLED; sb.border_color = _BORDER_LOCK
		add_theme_stylebox_override(state_name, sb)
	# small font for level/cost text
	add_theme_font_size_override("font_size", 9)

func _set_border_color(col: Color):
	for state_name in ["normal", "hover", "pressed"]:
		var sb: StyleBoxFlat = get_theme_stylebox(state_name)
		if sb:
			sb.border_color = col

# ── name label under the node ────────────────────────────────────────
func _create_name_label():
	if _name_label != null:
		return
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.9))
	_name_label.position = Vector2(-8, size.y + 2)
	_name_label.size = Vector2(size.x + 16, 14)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.text = _skill_display_name()
	add_child(_name_label)

	# Description label (what the skill does)
	_desc_label = Label.new()
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.add_theme_font_size_override("font_size", 7)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.7, 0.85))
	_desc_label.position = Vector2(-18, size.y + 16)
	_desc_label.size = Vector2(size.x + 36, 14)
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc_label.text = _skill_description()
	add_child(_desc_label)

	# Requirement label (shows unlock condition for locked nodes)
	_req_label = Label.new()
	_req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_req_label.add_theme_font_size_override("font_size", 7)
	_req_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3, 0.9))
	_req_label.position = Vector2(-18, size.y + 28)
	_req_label.size = Vector2(size.x + 36, 14)
	_req_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_req_label.visible = false
	add_child(_req_label)

func _skill_display_name() -> String:
	match skill_id:
		"str":   return "STR"
		"hp":    return "HP"
		"greed": return "GREED"
		"crit":  return "CRIT"
		"speed": return "SPEED"
		"def":   return "DEF"
	return skill_id.to_upper()

func _skill_description() -> String:
	match skill_id:
		"str":   return "DMG +1 per lvl"
		"hp":    return "Max HP +20"
		"greed": return "Gold +5%/lvl"
		"crit":  return "Crit +1%/lvl"
		"speed": return "Atk Spd up"
		"def":   return "DMG taken -2%"
	return ""

func _req_display_name(id: String) -> String:
	match id:
		"str": return "STR"
		"hp": return "HP"
		"greed": return "GREED"
		"crit": return "CRIT"
		"speed": return "SPEED"
		"def": return "DEF"
	return id.to_upper()

# ── juice ────────────────────────────────────────────────────────────
func _on_button_down():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.05)

func _on_button_up():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ── state update ─────────────────────────────────────────────────────
func update_state():
	if player == null: return

	var current_lvl = _get_player_skill_lvl()
	var cost = player.get_skill_cost(skill_id)

	var can_afford = false
	if currency_type == "gold":
		can_afford = player.gold >= cost
	else:
		var res_id = _get_res_id()
		can_afford = player.resources[res_id] >= cost

	var req_met = true
	if requirement_skill != "":
		var req_lvl = _get_player_skill_lvl(requirement_skill)
		req_met = req_lvl >= requirement_level

	# Always visible — never hide locked nodes
	visible = true
	disabled = not (req_met and can_afford and current_lvl < max_level)

	if current_lvl >= max_level:
		modulate = Color(1.0, 0.95, 0.7)
		_set_border_color(_BORDER_MAX)
		text = "MAX"
		if _req_label: _req_label.visible = false
		if _desc_label: _desc_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0, 0.9))
	elif not req_met:
		modulate = Color(0.45, 0.45, 0.45, 0.85)
		_set_border_color(_BORDER_LOCK)
		text = ""
		if _req_label:
			_req_label.text = "Need: %s Lv.%d" % [_req_display_name(requirement_skill), requirement_level]
			_req_label.visible = true
		if _desc_label: _desc_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.7))
	else:
		modulate = Color.WHITE
		var border_col = _BORDER_AVAIL if can_afford else _BORDER_DEF
		_set_border_color(border_col)
		var res_name = _get_resource_display_name()
		var suffix = "G" if currency_type == "gold" else _get_res_id().substr(0,1).to_upper()
		text = "L%d\n%d%s" % [current_lvl, cost, suffix]
		if _req_label:
			_req_label.text = "Cost: %d %s" % [cost, res_name]
			_req_label.visible = true
		if _desc_label: _desc_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.7, 0.85))

func _get_player_skill_lvl(id: String = ""):
	var target_id = id if id != "" else skill_id
	match target_id:
		"str": return player.str_lvl
		"crit": return player.crit_lvl
		"greed": return player.greed_lvl
		"speed": return player.speed_lvl
		"def": return player.def_lvl
		"hp": return int((player.max_hp - 100) / 20.0)
	return 0

func _get_res_id():
	match skill_id:
		"str", "greed": return "bandages"
		"crit", "speed": return "venom"
		"def": return "relic_shards"
	return "bandages"

func _get_resource_display_name() -> String:
	if currency_type == "gold":
		return "Gold"
	match skill_id:
		"str", "greed": return "Bandages"
		"crit", "speed": return "Venom"
		"def": return "Shards"
	return "Bandages"
