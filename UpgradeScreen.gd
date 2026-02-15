extends Control

signal upgrade_selected(id)

@onready var card_container = %CardContainer
var upgrade_manager = UpgradeManager.new()

func _ready():
	# Pozwalamy oknu działać, gdy gra jest zapauzowana
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup(player: PlayerStats):
	# Czyścimy stare karty
	for child in card_container.get_children():
		child.queue_free()
	
	# Losujemy 3 opcje
	var options = upgrade_manager.get_random_options(3)
	
	for opt in options:
		var btn = Button.new()
		btn.text = "%s
%s" % [opt.name, opt.desc]
		btn.custom_minimum_size = Vector2(200, 60)
		btn.pressed.connect(_on_card_pressed.bind(opt.id, player))
		card_container.add_child(btn)

func _on_card_pressed(id: String, player: PlayerStats):
	upgrade_manager.apply_upgrade(player, id)
	upgrade_selected.emit(id)
	queue_free()
	get_tree().paused = false
