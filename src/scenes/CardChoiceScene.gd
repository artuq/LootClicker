extends Control

@onready var card_container = %CardContainer
var upgrade_manager = UpgradeManager.new()
var player: PlayerStats

func setup(p_ref: PlayerStats):
	player = p_ref
	if not player:
		print("ERROR: CardChoiceScene.setup() - player is null!")
		queue_free()
		return
		
	get_tree().paused = true # Stop combat
	
	# Clear old cards
	for child in card_container.get_children():
		child.queue_free()
	
	# Roll 3 options
	var options = upgrade_manager.get_random_options(3)
	print("DEBUG: CardChoiceScene setup with %d options" % options.size())
	
	for opt in options:
		var card = create_card(opt)
		card_container.add_child(card)

func create_card(opt: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(140, 220)
	var is_cursed = opt.get("cursed", false)
	
	# Cursed card styling — dark red background
	if is_cursed:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.25, 0.05, 0.05, 0.95)
		style.border_color = Color(0.8, 0.1, 0.1)
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("normal", style)
		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.35, 0.08, 0.08, 0.95)
		hover_style.border_color = Color(1.0, 0.2, 0.2)
		btn.add_theme_stylebox_override("hover", hover_style)
		var pressed_style = style.duplicate()
		pressed_style.bg_color = Color(0.15, 0.02, 0.02, 0.95)
		btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vbox)
	
	# "CURSED" label at top
	if is_cursed:
		var curse_tag = Label.new()
		curse_tag.text = "⚠ CURSED"
		curse_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		curse_tag.add_theme_font_size_override("font_size", 10)
		curse_tag.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		vbox.add_child(curse_tag)
	
	# Ikona AI
	var tex_rect = TextureRect.new()
	var tex = load(opt.icon)
	if tex:
		tex_rect.texture = tex
	tex_rect.custom_minimum_size = Vector2(100, 100)
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vbox.add_child(tex_rect)
	
	# Tekst
	var lbl = Label.new()
	lbl.text = "%s\n%s" % [opt.name.to_upper(), opt.desc]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.custom_minimum_size = Vector2(120, 60)  # Force wrapping to card width
	lbl.add_theme_font_size_override("font_size", 9)  # Slightly smaller for fit
	if is_cursed:
		lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7))
	vbox.add_child(lbl)
	
	btn.pressed.connect(_on_card_selected.bind(opt))
	
	# Add juice
	btn.pivot_offset = btn.custom_minimum_size / 2
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	)
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	)
	
	return btn

func _on_card_selected(opt: Dictionary):
	if not player:
		print("ERROR: CardChoiceScene._on_card_selected() - player is null!")
		get_tree().paused = false
		queue_free()
		return
	
	# Cursed card — show confirmation dialog
	if opt.get("cursed", false):
		_show_curse_confirm(opt)
		return
	
	print("DEBUG: Card selected - %s" % opt.id)
	upgrade_manager.apply_upgrade(player, opt.id)
	get_tree().paused = false
	queue_free()

func _show_curse_confirm(opt: Dictionary):
	# Darken background
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	var panel = VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay.add_child(panel)
	
	var warn = Label.new()
	warn.text = "⚠ CURSED CARD ⚠\n%s\n\n%s\n\nAre you sure?" % [opt.name.to_upper(), opt.desc]
	warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn.add_theme_font_size_override("font_size", 14)
	warn.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	panel.add_child(warn)
	
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(btn_row)
	
	var yes_btn = Button.new()
	yes_btn.text = "ACCEPT CURSE"
	yes_btn.custom_minimum_size = Vector2(120, 40)
	var yes_style = StyleBoxFlat.new()
	yes_style.bg_color = Color(0.6, 0.1, 0.1)
	yes_style.set_corner_radius_all(6)
	yes_btn.add_theme_stylebox_override("normal", yes_style)
	btn_row.add_child(yes_btn)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	btn_row.add_child(spacer)
	
	var no_btn = Button.new()
	no_btn.text = "CANCEL"
	no_btn.custom_minimum_size = Vector2(100, 40)
	btn_row.add_child(no_btn)
	
	yes_btn.pressed.connect(func():
		overlay.queue_free()
		print("DEBUG: Cursed card accepted - %s" % opt.id)
		upgrade_manager.apply_upgrade(player, opt.id)
		get_tree().paused = false
		queue_free()
	)
	
	no_btn.pressed.connect(func():
		overlay.queue_free()  # Just close dialog, let player pick again
	)
