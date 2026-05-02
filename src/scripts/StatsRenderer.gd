extends Node

var _combat_stats_panel: PanelContainer
var _skill_stats_panel: PanelContainer
var _player: Node
var _format_fn: Callable

func setup(refs: Dictionary):
	_combat_stats_panel = refs.get("combat_stats_panel")
	_skill_stats_panel = refs.get("skill_stats_panel")
	_player = refs.get("player")
	_format_fn = refs.get("format_fn", Callable())

func update_stats():
	if not _combat_stats_panel or not _skill_stats_panel or not _player:
		return
	_setup_panels_style()

	var dmg = _player.get_total_damage()
	var spd = _player.get_attack_speed()
	var total_crit = _player.crit_lvl + _player.card_crit
	var total_def = _player.def_lvl + _player.card_def
	var total_greed = _player.greed_lvl + _player.card_greed
	var crit_ch = min(80.0, total_crit * 1.0)
	var crit_m = _player.get_crit_multiplier()
	var def_red = min(50.0, total_def * 2.0)
	var gold_b = total_greed * 5
	var dodge = _player.dodge_chance * 100.0
	var block = _player.block_chance * 100.0

	var base_hp_level = int((_player.max_hp - 100 - _player.card_hp * 20) / 20.0)
	var skill_rows: Array[Dictionary] = [
		{"name": "STR", "kind": "base_bonus", "base": _player.str_lvl, "bonus": _player.card_str},
		{"name": "HP", "kind": "base_bonus", "base": base_hp_level, "bonus": _player.card_hp},
		{"name": "Greed", "kind": "base_bonus", "base": _player.greed_lvl, "bonus": _player.card_greed},
		{"name": "Crit", "kind": "base_bonus", "base": _player.crit_lvl, "bonus": _player.card_crit},
		{"name": "Speed", "kind": "base_bonus", "base": _player.speed_lvl, "bonus": _player.card_speed},
		{"name": "DEF", "kind": "base_bonus", "base": _player.def_lvl, "bonus": _player.card_def},
	]
	var skill_sections: Array[Dictionary] = [
		{"title": "BASE SKILLS", "rows": skill_rows}
	]
	if _player.active_curses.size() > 0:
		var curse_rows: Array[Dictionary] = []
		for c in _player.active_curses:
			var cname = str(c.get("id", "?")).replace("curse_", "").capitalize()
			var stages = int(c.get("stages", 0))
			curse_rows.append({"name": cname, "kind": "plain", "value": "-%d" % stages, "color": Color(1.0, 0.45, 0.45, 1.0)})
		skill_sections.append({"title": "CURSES", "rows": curse_rows})
	_render_panel(_combat_stats_panel, skill_sections)

	var dps: float = float(dmg) / max(0.01, spd)
	var def_str: String
	var def_color: Color
	if def_red >= 0:
		def_str = "-%.0f%%" % def_red
		def_color = Color(0.18, 0.12, 0.06, 1.0)
	else:
		def_str = "+%.0f%% dmg" % absf(def_red)
		def_color = Color(1.0, 0.3, 0.3, 1.0)

	var combat_rows: Array[Dictionary] = [
		{"name": "DPS", "kind": "plain", "value": "%.1f" % dps, "color": Color(0.75, 0.45, 0.05, 1.0)},
		{"name": "DMG", "kind": "plain", "value": str(dmg)},
		{"name": "SPD", "kind": "plain", "value": "%.2fs" % spd},
		{"name": "Crit", "kind": "plain", "value": "%.0f%%" % crit_ch},
		{"name": "Crit DMG", "kind": "plain", "value": "x%.2f" % crit_m},
		{"name": "DEF", "kind": "plain", "value": def_str, "color": def_color},
	]
	if gold_b > 0:
		combat_rows.append({"name": "Gold", "kind": "plain", "value": "+%d%%" % gold_b, "color": Color(0.6, 0.45, 0.05, 1.0)})
	if dodge > 0:
		combat_rows.append({"name": "Dodge", "kind": "plain", "value": "%.0f%%" % dodge})
	if block > 0:
		combat_rows.append({"name": "Block", "kind": "plain", "value": "%.0f%%" % block})
	var combat_sections: Array[Dictionary] = [{"title": "COMBAT STATS", "rows": combat_rows}]
	if _player.prestige_level > 0:
		var prestige_rows: Array[Dictionary] = [
			{"name": "Rebirth", "kind": "plain", "value": "x%d" % _player.prestige_level, "color": Color(1.0, 0.85, 0.3)},
			{"name": "Soul Shards", "kind": "plain", "value": str(_player.soul_shards), "color": Color(0.7, 0.5, 1.0)},
			{"name": "DMG Bonus", "kind": "plain", "value": "+%.0f%%" % _player.get_prestige_dmg_bonus(), "color": Color(1.0, 0.85, 0.3)},
			{"name": "Gold Bonus", "kind": "plain", "value": "+%.0f%%" % _player.get_prestige_gold_bonus(), "color": Color(1.0, 0.85, 0.3)},
		]
		combat_sections.append({"title": "PRESTIGE", "rows": prestige_rows})
	_render_panel(_skill_stats_panel, combat_sections)

func _setup_panels_style():
	for panel_node in [_combat_stats_panel, _skill_stats_panel]:
		if not panel_node:
			continue
		panel_node.custom_minimum_size = Vector2(0, 170)
		var panel_style := StyleBoxFlat.new()
		# Parchment / scroll style background
		panel_style.bg_color = Color(0.82, 0.74, 0.58, 0.95)
		panel_style.set_corner_radius_all(6)
		panel_style.set_border_width_all(3)
		panel_style.border_color = Color(0.52, 0.38, 0.22, 0.95)
		panel_style.content_margin_left = 10
		panel_style.content_margin_top = 10
		panel_style.content_margin_right = 10
		panel_style.content_margin_bottom = 10
		# Inner shadow for depth
		panel_style.shadow_color = Color(0.35, 0.28, 0.16, 0.35)
		panel_style.shadow_size = 4
		panel_node.add_theme_stylebox_override("panel", panel_style)
		# Slide-in animation from bottom
		panel_node.modulate.a = 0.0
		panel_node.position.y += 30.0
		var idx: int = 0 if panel_node == _combat_stats_panel else 1
		var delay: float = idx * 0.08
		var orig_y: float = panel_node.position.y - 30.0
		var t: Tween = panel_node.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(panel_node, "modulate:a", 1.0, 0.25).set_delay(delay)
		t.tween_property(panel_node, "position:y", orig_y, 0.3).set_delay(delay)

func _render_panel(panel: PanelContainer, sections: Array[Dictionary]) -> void:
	var rows_box: VBoxContainer = panel.get_node_or_null("Rows") as VBoxContainer
	if rows_box == null:
		rows_box = VBoxContainer.new()
		rows_box.name = "Rows"
		rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rows_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		rows_box.add_theme_constant_override("separation", 2)
		panel.add_child(rows_box)
	for child in rows_box.get_children():
		child.queue_free()
	var row_index := 0
	for section in sections:
		var section_title: String = str(section.get("title", ""))
		var section_rows: Array = section.get("rows", [])
		var header := _create_section_header(section_title)
		rows_box.add_child(header)
		_animate_row_in(header, row_index)
		row_index += 1
		for i in section_rows.size():
			var row_ctrl := _create_row(section_rows[i], i % 2 == 0)
			rows_box.add_child(row_ctrl)
			_animate_row_in(row_ctrl, row_index)
			row_index += 1

func _animate_row_in(node: Control, index: int):
	node.modulate.a = 0.0
	node.position.x += 20.0
	var delay: float = index * 0.03
	var original_x: float = node.position.x - 20.0
	var tween: Tween = node.create_tween()
	tween.set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 1.0, 0.2).set_delay(delay)
	tween.tween_property(node, "position:x", original_x, 0.25).set_delay(delay)

func _create_section_header(text: String) -> Control:
	var header_panel := PanelContainer.new()
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color(0.45, 0.32, 0.18, 0.85)
	hs.set_corner_radius_all(3)
	hs.content_margin_left = 6
	hs.content_margin_right = 6
	hs.content_margin_top = 3
	hs.content_margin_bottom = 3
	header_panel.add_theme_stylebox_override("panel", hs)
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.82, 1.0))
	label.add_theme_font_size_override("font_size", 11)
	header_panel.add_child(label)
	return header_panel

func _create_row(row_data: Dictionary, alt: bool) -> Control:
	var row_panel := PanelContainer.new()
	var rs := StyleBoxFlat.new()
	rs.bg_color = Color(0.72, 0.65, 0.50, 0.45) if alt else Color(0.76, 0.68, 0.52, 0.25)
	rs.content_margin_left = 4
	rs.content_margin_right = 4
	rs.content_margin_top = 2
	rs.content_margin_bottom = 2
	row_panel.add_theme_stylebox_override("panel", rs)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row_panel.add_child(row)

	var name_label := Label.new()
	name_label.text = str(row_data.get("name", "-"))
	name_label.custom_minimum_size = Vector2(82, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_stretch_ratio = 4.0
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.2, 0.15, 0.08, 1.0))

	var sep_label := Label.new()
	sep_label.text = ":"
	sep_label.custom_minimum_size = Vector2(10, 0)
	sep_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sep_label.size_flags_horizontal = Control.SIZE_FILL
	sep_label.size_flags_stretch_ratio = 1.0
	sep_label.add_theme_color_override("font_color", Color(0.4, 0.33, 0.22, 1.0))

	var value_wrap := HBoxContainer.new()
	value_wrap.alignment = BoxContainer.ALIGNMENT_END
	value_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_wrap.size_flags_stretch_ratio = 3.0

	if str(row_data.get("kind", "plain")) == "base_bonus":
		var base_val: int = int(row_data.get("base", 0))
		var bonus_val: int = int(row_data.get("bonus", 0))
		var base_label := Label.new()
		base_label.text = str(base_val)
		base_label.add_theme_font_size_override("font_size", 10)
		base_label.add_theme_color_override("font_color", Color(0.18, 0.12, 0.06, 1.0))
		value_wrap.add_child(base_label)
		if bonus_val != 0:
			var bonus_label := Label.new()
			if bonus_val > 0:
				bonus_label.text = " +%d" % bonus_val
				bonus_label.add_theme_color_override("font_color", Color(0.1, 0.5, 0.15, 1.0))
			else:
				bonus_label.text = " %d" % bonus_val
				bonus_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1.0))
			bonus_label.add_theme_font_size_override("font_size", 10)
			value_wrap.add_child(bonus_label)
	else:
		var value_label := Label.new()
		value_label.text = str(row_data.get("value", "-"))
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.add_theme_font_size_override("font_size", 10)
		if row_data.has("color"):
			value_label.add_theme_color_override("font_color", row_data["color"])
		else:
			value_label.add_theme_color_override("font_color", Color(0.18, 0.12, 0.06, 1.0))
		value_wrap.add_child(value_label)

	row.add_child(name_label)
	row.add_child(sep_label)
	row.add_child(value_wrap)
	return row_panel
