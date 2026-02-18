extends PanelContainer
class_name InventorySlot

@onready var icon_rect = %Icon
@onready var count_label = %Count

func set_item(texture: Texture2D, count: int = 1, rarity_color: Color = Color.WHITE):
	if not is_node_ready():
		await ready
	icon_rect.texture = texture
	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false
	
	# Set border color or something to show rarity
	var style = get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		style.border_color = rarity_color
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		add_theme_stylebox_override("panel", style)
