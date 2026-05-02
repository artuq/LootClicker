extends Node

const BOTTOM_NAV_HEIGHT := 56.0
const NAV_ACTIVE_COLOR := Color(1.0, 0.9, 0.65, 1.0)
const NAV_IDLE_COLOR := Color(0.75, 0.75, 0.75, 1.0)

var _tab_switch_tween: Tween = null
var _panel_height_tween: Tween = null
var _bottom_panel_open: bool = false

var _bottom_panel: Panel
var _bottom_content_area: MarginContainer
var _bottom_tab_container: TabContainer
var _nav_inventory_btn: Button
var _nav_stats_btn: Button
var _owner_node: Node

func setup(refs: Dictionary):
	_owner_node = refs.get("owner")
	_bottom_panel = refs.get("bottom_panel")
	_bottom_content_area = refs.get("bottom_content_area")
	_bottom_tab_container = refs.get("bottom_tab_container")
	_nav_inventory_btn = refs.get("nav_inventory_btn")
	_nav_stats_btn = refs.get("nav_stats_btn")

func setup_navigation(add_juice_fn: Callable):
	if not _bottom_tab_container or not _bottom_panel:
		return

	if _nav_inventory_btn and not _nav_inventory_btn.pressed.is_connected(_on_nav_inventory_pressed):
		_nav_inventory_btn.pressed.connect(_on_nav_inventory_pressed)
		add_juice_fn.call(_nav_inventory_btn)
	if _nav_stats_btn and not _nav_stats_btn.pressed.is_connected(_on_nav_stats_pressed):
		_nav_stats_btn.pressed.connect(_on_nav_stats_pressed)
		add_juice_fn.call(_nav_stats_btn)

	_bottom_panel.visible = true
	_bottom_panel.anchor_top = 1.0
	_bottom_panel.anchor_bottom = 1.0
	_bottom_panel.offset_bottom = 0.0
	_bottom_panel.offset_top = -BOTTOM_NAV_HEIGHT
	if _bottom_content_area:
		_bottom_content_area.visible = false
		_bottom_content_area.modulate.a = 0.0
	_bottom_tab_container.current_tab = 0
	_update_visuals(-1)

func set_tab(tab_index: int, animated: bool = true):
	if not _bottom_tab_container:
		return
	if tab_index < 0 or tab_index >= _bottom_tab_container.get_tab_count():
		return
	if _bottom_panel_open and _bottom_tab_container.current_tab == tab_index:
		_close_panel()
		return
	if not _bottom_panel_open:
		_open_panel(tab_index)
		return
	if _tab_switch_tween:
		_tab_switch_tween.kill()
	if animated:
		await _animate_tab_switch(tab_index)
	else:
		_bottom_tab_container.current_tab = tab_index
		_update_visuals(tab_index)

func _update_visuals(active_index: int):
	var buttons: Array[Button] = [_nav_inventory_btn, _nav_stats_btn]
	for i in buttons.size():
		var btn := buttons[i]
		if not btn:
			continue
		btn.z_index = 1 if i == active_index else 0
		var target_color := NAV_ACTIVE_COLOR if i == active_index else NAV_IDLE_COLOR
		var target_scale := Vector2(1.03, 1.03) if i == active_index else Vector2(1.0, 1.0)
		var tween := _owner_node.create_tween()
		tween.tween_property(btn, "modulate", target_color, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(btn, "scale", target_scale, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_nav_inventory_pressed():
	_juice_nav_press(_nav_inventory_btn)
	set_tab(0, true)

func _on_nav_stats_pressed():
	_juice_nav_press(_nav_stats_btn)
	set_tab(1, true)

func _open_panel(tab_index: int):
	if not _bottom_panel or not _bottom_tab_container:
		return
	_bottom_panel_open = true
	if _bottom_content_area:
		_bottom_content_area.visible = true
		_bottom_content_area.modulate.a = 1.0
	_bottom_tab_container.current_tab = tab_index
	_bottom_tab_container.modulate.a = 0.0
	_bottom_tab_container.position = Vector2(34, 0)
	_update_visuals(tab_index)
	await _animate_panel_height(true)
	var reveal := _owner_node.create_tween()
	reveal.tween_property(_bottom_tab_container, "modulate:a", 1.0, 0.13)
	reveal.parallel().tween_property(_bottom_tab_container, "position", Vector2.ZERO, 0.13).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_panel():
	if not _bottom_panel:
		return
	_bottom_panel_open = false
	_update_visuals(-1)
	if _bottom_content_area:
		var fade := _owner_node.create_tween()
		fade.tween_property(_bottom_content_area, "modulate:a", 0.0, 0.09)
		await fade.finished
		_bottom_content_area.visible = false
	await _animate_panel_height(false)

func _animate_panel_height(open_state: bool):
	if not _bottom_panel:
		return
	if _panel_height_tween:
		_panel_height_tween.kill()
	var viewport_h: float = _owner_node.get_viewport().get_visible_rect().size.y
	var expanded_height: float = maxf(260.0, floorf(viewport_h * 0.60))
	var target_top: float = -expanded_height if open_state else -BOTTOM_NAV_HEIGHT
	_panel_height_tween = _owner_node.create_tween()
	var trans = Tween.TRANS_BACK if open_state else Tween.TRANS_SINE
	_panel_height_tween.tween_property(_bottom_panel, "offset_top", target_top, 0.22).set_trans(trans).set_ease(Tween.EASE_OUT)
	await _panel_height_tween.finished

func _animate_tab_switch(tab_index: int):
	if not _bottom_tab_container:
		return
	if _tab_switch_tween:
		_tab_switch_tween.kill()
	_tab_switch_tween = _owner_node.create_tween()
	_tab_switch_tween.tween_property(_bottom_tab_container, "modulate:a", 0.0, 0.08)
	_tab_switch_tween.parallel().tween_property(_bottom_tab_container, "position", Vector2(-30, 0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await _tab_switch_tween.finished
	_bottom_tab_container.current_tab = tab_index
	_update_visuals(tab_index)
	_bottom_tab_container.position = Vector2(30, 0)
	_tab_switch_tween = _owner_node.create_tween()
	_tab_switch_tween.tween_property(_bottom_tab_container, "modulate:a", 1.0, 0.12)
	_tab_switch_tween.parallel().tween_property(_bottom_tab_container, "position", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _juice_nav_press(btn: Button):
	if not btn:
		return
	var pulse := _owner_node.create_tween()
	pulse.tween_property(btn, "scale", Vector2(0.93, 0.93), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pulse.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pulse.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
