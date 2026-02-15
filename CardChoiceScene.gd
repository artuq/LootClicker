extends Control

@onready var card_container = %CardContainer
var upgrade_manager = UpgradeManager.new()
var player: PlayerStats

func setup(p_ref: PlayerStats):
	player = p_ref
	get_tree().paused = true # Zatrzymujemy walkę
	
	# Czyścimy stare karty
	for child in card_container.get_children():
		child.queue_free()
	
	# Losujemy 3 opcje
	var options = upgrade_manager.get_random_options(3)
	
	for opt in options:
		var card = create_card(opt)
		card_container.add_child(card)

func create_card(opt: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(140, 220)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vbox)
	
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
	lbl.add_theme_font_size_override("font_size", 10)
	vbox.add_child(lbl)
	
	btn.pressed.connect(_on_card_selected.bind(opt.id))
	return btn

func _on_card_selected(id: String):
	upgrade_manager.apply_upgrade(player, id)
	get_tree().paused = false
	queue_free()
