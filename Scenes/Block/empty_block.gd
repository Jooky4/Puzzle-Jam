extends Control

@onready var texture = $TextureRect
var can_drop_block : bool = true
var active : bool = true
var select : bool = false

func add_block() -> void:
	not_can_drop()
	select = false
	$TextureRect.use_parent_material = true

func set_not_active() -> void:
	active = false
	can_drop_block = false
	self.custom_minimum_size = Vector2(0, 0)
	$TextureRect.visible = false

func not_can_drop() -> void:
	can_drop_block = false

func _on_mouse_entered() -> void:
	if can_drop_block:
		select = true
		$TextureRect.use_parent_material = false

func _on_mouse_exited() -> void:
	if can_drop_block:
		select = false
		$TextureRect.use_parent_material = true

func free_block() -> void:
	can_drop_block = true
	active = true
	select = false
