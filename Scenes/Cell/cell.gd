class_name Cell2D extends Control


@export_enum("normal", "ads") var cell_type: String: set = _set_cell_type

var level_position: Vector2i

@onready var texture_rect = $TextureRect
@onready var ads_button: TextureButton = $AdsButton

var can_drop_block: bool = true
var active: bool = true
var select: bool = false

signal show_ads


func _ready() -> void:
	_update_ui()


func _to_string() -> String:
	return "<Cell %s %s>" % [name, "empty" if can_drop_block else "non empty"]


func _update_ui() -> void:
	if ads_button:
		ads_button.visible = cell_type == "ads"

	if texture_rect:
		texture_rect.visible = is_active()


func add_block() -> void:
	not_can_drop()
	select = false
	set_highlighted(false)


func _set_cell_type(value: String) -> void:
	cell_type = value
	_update_ui()


func is_active() -> bool:
	return active


func set_active(value: bool) -> void:
	active = false
	can_drop_block = false
	self.custom_minimum_size = Vector2(0, 0)

	_update_ui()


func not_can_drop() -> void:
	can_drop_block = false


func _on_mouse_entered() -> void:
	if can_drop_block:
		select = true
		set_highlighted(true)


func _on_mouse_exited() -> void:
	if can_drop_block:
		select = false
		set_highlighted(false)


func free_block() -> void:
	can_drop_block = true
	active = true
	select = false


# TODO: переделать
func set_highlighted(value: bool) -> void:
	var active_color = Color(1, 1, 1, 1.0)
	var inactive_color = Color(0.8, 0.8, 0.8, 1.0)
	var color: Color
	#if value:
		#color = active_color
	#else:
		#color = inactive_color
#
	#texture_rect.modulate = color


func get_color_block() -> ColorBlock2D:
	if active and not can_drop_block:
		var child = get_child(-1)
		return child
	else:
		return null


func _on_button_pressed() -> void:
	prints("cell pressed")
	show_ads.emit()
