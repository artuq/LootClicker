extends PanelContainer
class_name InventorySlot

signal slot_pressed(item_data: Dictionary)

@onready var icon_rect = %Icon
@onready var count_label = %Count

var _item_data: Dictionary = {}
var _selected: bool = false
var _base_rarity_color: Color = Color.WHITE

func set_item(texture: Texture2D, count: int = 1, rarity_color: Color = Color.WHITE, item_data: Dictionary = {}):
	if not is_node_ready():
		await ready
	_item_data = item_data
	_base_rarity_color = rarity_color
	icon_rect.texture = texture
	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false
	_apply_border(rarity_color)

func _apply_border(color: Color, width: int = 2):
	var style = get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		style.border_color = color
		style.set_border_width_all(width)
		add_theme_stylebox_override("panel", style)

func set_selected(val: bool):
	_selected = val
	if _selected:
		_apply_border(Color.GOLD, 3)
	else:
		_apply_border(_base_rarity_color, 2)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _item_data.size() > 0:
			slot_pressed.emit(_item_data)
			accept_event()
