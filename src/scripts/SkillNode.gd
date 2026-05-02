extends Button
class_name SkillNode

@export var skill_id: String = "str"
@export var currency_type: String = "resource" # "gold" lub "resource"
@export var max_level: int = 50
@export var requirement_skill: String = ""
@export var requirement_level: int = 0
@export var icon_texture: Texture2D

var player: PlayerStats
var _icon_rect: TextureRect
var _name_label: Label
var _req_label: Label
var _state: int = 0
var _current_level: int = 0
var _current_cost: int = 0
var _can_afford: bool = false
var _req_met: bool = true
var _selected: bool = false

const STATE_LOCKED := 0
const STATE_UNLOCKED := 1
const STATE_AVAILABLE := 2
const STATE_MAX := 3

# ── theme colours ────────────────────────────────────────────────────
const _HEX_BG := Color(0.06, 0.11, 0.18, 1.0)
const _LINE_LOCKED := Color(0.55, 0.62, 0.78, 0.9)
const _LINE_UNLOCKED := Color(0.2, 0.92, 0.45, 1.0)
const _LINE_AVAILABLE := Color(0.35, 1.0, 0.8, 1.0)
const _LINE_MAX := Color(1.0, 0.9, 0.35, 1.0)

func setup(p_ref: PlayerStats):
	player = p_ref
	custom_minimum_size = Vector2(max(64.0, custom_minimum_size.x), max(64.0, custom_minimum_size.y))
	clip_text = false
	text = ""
	_apply_flat_theme()
	_create_icon_rect()
	# Labels are intentionally omitted — popup shows all info on tap

	pivot_offset = size / 2
	if not button_down.is_connected(_on_button_down):
		button_down.connect(_on_button_down)
	if not button_up.is_connected(_on_button_up):
		button_up.connect(_on_button_up)

	update_state()

# ── transparent styleboxes (custom draw handles visuals) ────────────
func _apply_flat_theme():
	for state_name in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_width_left = 0
		sb.border_width_right = 0
		sb.border_width_top = 0
		sb.border_width_bottom = 0
		add_theme_stylebox_override(state_name, sb)

func _create_icon_rect():
	if _icon_rect != null:
		return
	_icon_rect = TextureRect.new()
	_icon_rect.anchor_left = 0.5
	_icon_rect.anchor_top = 0.5
	_icon_rect.anchor_right = 0.5
	_icon_rect.anchor_bottom = 0.5
	_icon_rect.offset_left = -24.0
	_icon_rect.offset_top = -24.0
	_icon_rect.offset_right = 24.0
	_icon_rect.offset_bottom = 24.0
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if icon_texture:
		_icon_rect.texture = icon_texture
	add_child(_icon_rect)

# ── name label under the node ────────────────────────────────────────
func _create_name_label():
	if _name_label != null:
		return

	# Name label
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0, 1.0))
	_name_label.position = Vector2(-10, size.y + 2)
	_name_label.size = Vector2(size.x + 20, 18)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.text = _skill_display_name()
	var name_ls := LabelSettings.new()
	name_ls.outline_size = 3
	name_ls.outline_color = Color(0, 0, 0, 0.85)
	_name_label.label_settings = name_ls
	add_child(_name_label)

	# Cost/req label — single compact line, no description
	_req_label = Label.new()
	_req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_req_label.add_theme_font_size_override("font_size", 11)
	_req_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	_req_label.position = Vector2(-14, size.y + 18)
	_req_label.size = Vector2(size.x + 28, 18)
	_req_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var req_ls := LabelSettings.new()
	req_ls.outline_size = 2
	req_ls.outline_color = Color(0, 0, 0, 0.8)
	_req_label.label_settings = req_ls
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

func set_selected(val: bool):
	_selected = val
	queue_redraw()

# ── state update ─────────────────────────────────────────────────────
func update_state():
	if player == null: return

	_current_level = _get_player_skill_lvl()
	_current_cost = player.get_skill_cost(skill_id)

	_can_afford = false
	if currency_type == "gold":
		_can_afford = player.gold >= _current_cost
	else:
		var res_id = _get_res_id()
		_can_afford = player.resources[res_id] >= _current_cost

	_req_met = true
	if requirement_skill != "":
		var req_lvl = _get_player_skill_lvl(requirement_skill)
		_req_met = req_lvl >= requirement_level

	# Always visible — never hide locked nodes
	visible = true
	# Only block taps on max-level nodes; locked/unaffordable handled in purchase logic
	disabled = (_current_level >= max_level)
	text = ""

	if _current_level >= max_level:
		_state = STATE_MAX
		modulate = Color(1.0, 1.0, 0.95, 1.0)
	elif not _req_met:
		_state = STATE_LOCKED
		modulate = Color(0.8, 0.8, 0.88, 0.88)
	else:
		modulate = Color.WHITE
		if _can_afford:
			_state = STATE_AVAILABLE
		elif _current_level > 0:
			_state = STATE_UNLOCKED
		else:
			_state = STATE_LOCKED

	queue_redraw()

func _draw():
	var center := size * 0.5
	var radius: float = min(size.x, size.y) * 0.47
	var inner_radius: float = radius - 7.0
	var border_col := _state_color()

	_draw_hex(center, radius + 6.0, Color(border_col.r, border_col.g, border_col.b, 0.18), true)
	_draw_hex(center, radius, border_col, false)
	_draw_hex(center, inner_radius, _HEX_BG, true)

	if _selected:
		_draw_hex(center, radius + 12.0, Color(1.0, 1.0, 0.4, 0.35), true)
		_draw_hex(center, radius + 12.0, Color(1.0, 1.0, 0.3, 0.9), false)
	elif has_focus() or is_hovered():
		_draw_hex(center, radius + 10.0, Color(border_col.r, border_col.g, border_col.b, 0.12), true)

	if _current_level > 0:
		var badge_pos := center + Vector2(-radius * 0.55, -radius * 0.55)
		draw_circle(badge_pos, 11.0, Color(0.05, 0.1, 0.16, 0.95))
		draw_arc(badge_pos, 11.0, 0.0, TAU, 22, border_col, 2.0)
		var font := ThemeDB.fallback_font
		if font != null:
			draw_string(font, badge_pos + Vector2(-7, 4), "x%d" % _current_level, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(0.92, 0.96, 1.0, 0.95))

func _draw_hex(center: Vector2, radius: float, col: Color, filled: bool):
	var pts := PackedVector2Array()
	for i in 6:
		var a := deg_to_rad(60.0 * i - 30.0)
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	if filled:
		draw_polygon(pts, PackedColorArray([col]))
	else:
		pts.append(pts[0])
		draw_polyline(pts, col, 2.8, true)

func _state_color() -> Color:
	match _state:
		STATE_MAX:
			return _LINE_MAX
		STATE_AVAILABLE:
			return _LINE_AVAILABLE
		STATE_UNLOCKED:
			return _LINE_UNLOCKED
		_:
			return _LINE_LOCKED

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

func _get_currency_short() -> String:
	if currency_type == "gold":
		return "G"
	match skill_id:
		"str", "greed": return "B"
		"crit", "speed": return "V"
		"def": return "S"
	return "B"
