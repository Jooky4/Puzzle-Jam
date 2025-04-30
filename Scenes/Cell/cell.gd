extends Control

@onready var texture_rect = $TextureRect

var can_drop_block: bool = true
var active: bool = true
var select: bool = false


func _to_string() -> String:
	return "<Cell %s %s>" % [name, "empty" if can_drop_block else "non empty"]


func _update_ui() -> void:
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


func set_highlighted(value: bool) -> void:
	var active_color = Color(0.26, 0.26, 0.26, 1.0)
	var inactive_color = Color(0.22, 0.22, 0.22, 1.0)
	var color: Color

	if value:
		color = active_color
	else:
		color = inactive_color

	texture_rect.texture.gradient.colors[0] = color
