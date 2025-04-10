extends Control

@onready var texture = $TextureRect
@onready var can_drop_block : bool = true
@onready var select : bool = false

func add_block() -> void:
	not_can_drop()
	select = false
	$TextureRect.use_parent_material = true

func set_not_active() -> void:
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
