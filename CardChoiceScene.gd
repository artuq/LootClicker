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
	btn.text = "%s

%s" % [opt.name.to_upper(), opt.desc]
	btn.custom_minimum_size = Vector2(100, 150)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD
	btn.pressed.connect(_on_card_selected.bind(opt.id))
	return btn

func _on_card_selected(id: String):
	upgrade_manager.apply_upgrade(player, id)
	get_tree().paused = false
	queue_free()
