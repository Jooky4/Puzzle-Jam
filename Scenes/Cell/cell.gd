extends Control


@export_enum("normal", "ads") var cell_type: String
@export var simple_texture: Texture2D
@export var ads_texture: Texture2D

@onready var texture_rect = $TextureRect
@onready var ads_button: Button = $AdsButton

var can_drop_block: bool = true
var active: bool = true
var select: bool = false


func _to_string() -> String:
	return "<Cell %s %s>" % [name, "empty" if can_drop_block else "non empty"]


func _update_ui() -> void:
	ads_button.visible = cell_type == "ads"

	if texture_rect:
		texture_rect.visible = is_active()


func add_block() -> void:
	not_can_drop()
	select = false
	set_highlighted(false)


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


func _on_button_pressed() -> void:
	prints("cell pressed")
