extends Control

signal upgrade_selected(id)

@onready var card_container = %CardContainer
var upgrade_manager = UpgradeManager.new()

func _ready():
	# Allow window to process while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup(player: PlayerStats):
	# Allow window to process while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if card_container == null:
		card_container = %CardContainer
	
	# Emit gold change to refresh UI in PlayerStats if needed
	player.gold_changed.emit(player.gold)
	
	# Clear old cards
	for child in card_container.get_children():
		child.queue_free()
	
	# Roll 3 options
	var options = upgrade_manager.get_random_options(3)
	
	for opt in options:
		var btn = Button.new()
		btn.text = "%s\n%s" % [opt.name, opt.desc]
		btn.custom_minimum_size = Vector2(200, 60)
		btn.pressed.connect(_on_card_pressed.bind(opt.id, player))
		card_container.add_child(btn)

func _on_card_pressed(id: String, player: PlayerStats):
	upgrade_manager.apply_upgrade(player, id)
	upgrade_selected.emit(id)
	queue_free()
	get_tree().paused = false
