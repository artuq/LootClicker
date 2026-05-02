extends SceneTree

func _init():
	var file = FileAccess.open("res://logs/layout_result.txt", FileAccess.WRITE)
	file.store_string("Starting test...\n")
	
	var scene = load("res://src/scenes/CardChoiceScene.tscn").instantiate()
	root.add_child(scene)
	
	var container = scene.find_child("CardContainer", true, false)
	for c in container.get_children():
		c.queue_free()
		
	var opt1 = {"name": "Short", "desc": "One line.", "icon": "res://assets/icons/bandage.png"}
	var opt2 = {"name": "Medium", "desc": "This is a two line description.", "icon": "res://assets/icons/bandage.png"}
	var opt3 = {"name": "Long", "desc": "This is a very long description that will absolutely force the label to wrap into three or more lines.", "icon": "res://assets/icons/bandage.png"}
	
	container.add_child(scene.create_card(opt1))
	container.add_child(scene.create_card(opt2))
	container.add_child(scene.create_card(opt3))
	
	for i in range(3):
		await process_frame
		
	file.store_string("--- LAYOUT RESULTS ---\n")
	var i = 1
	for card in container.get_children():
		var y_pos = card.global_position.y
		var h = card.size.y
		file.store_string("Card %d: Pos Y = %.2f | Height = %.2f\n" % [i, y_pos, h])
		i += 1
		
	file.store_string("Test complete.\n")
	file.close()
	quit()
