class_name ColorTile2D extends Control

@export var color: int: set = _set_color

@export var gold_lock_texture: Texture2D
@export var silver_lock_texture: Texture2D
@export var bronze_lock_texture: Texture2D

@export var jelly_lerp_speed: float = 8.0
@export var jelly_offset_scale1: float = 0.5
@export var jelly_offset_scale2: float = 0.3


@onready var key_node: Control = $Key
@onready var key_star_animation: AnimationPlayer = $Key/AnimationPlayer
@onready var key_sprite: Control = $Key/Key

@onready var lock_node: TextureRect = $Lock

var _color_tile: ColorTile
var velocity: Vector2
var is_fly: bool = false

var layers: Dictionary


func get_color() -> int:
	return _color_tile.color


func get_color_value() -> int:
	return _color_tile.color_value


func get_rgb_color() -> Color:
	return _color_tile.rgb_color


func _set_color(value: int) -> void:
	#prints("ColorTile._set_color()", value)
	_color_tile = ColorTile.create_from_color(value)

	var child_list = get_children()
	child_list[0].modulate = _color_tile.rgb_color.darkened(0.3)
	child_list[1].modulate = _color_tile.rgb_color.darkened(0.3)
	child_list[2].modulate = _color_tile.rgb_color

	_update_ui()


func _ready() -> void:
	lock_node.hide()
	key_node.hide()

	var children = get_children()
	layers = {
		"patch1": children[1],
		"patch2": children[2],
		"patch3": children[3],
		"pos1": children[1].position,
		"pos2": children[2].position
	}
	if _color_tile:
		_update_ui()


func is_iced() -> bool:
	return _color_tile.is_iced()


func is_live() -> bool:
	return _color_tile.is_live()


func _update_ui() -> void:
	if lock_node:
		if _color_tile.is_lock():
			lock_node.show()

			match _color_tile.type:
				ColorTile.Type.LOCK_1:
					lock_node.texture = bronze_lock_texture
				ColorTile.Type.LOCK_2:
					lock_node.texture = silver_lock_texture
				ColorTile.Type.LOCK_3:
					lock_node.texture = gold_lock_texture
		else:
			lock_node.hide()

	if key_node:
		if _color_tile.is_key():
			key_node.show()
			key_star_animation.play("star")
			key_sprite.type = _color_tile.type

		else:
			key_node.hide()
			key_star_animation.play("RESET")


func _process(delta: float) -> void:
	if is_fly:
		# Обновляем желейные слои
		#var control = layer["control"]
		var patch1 = layers["patch1"]
		var patch2 = layers["patch2"]
		var patch3 = layers["patch3"]
		var base_pos1: Vector2 = layers["pos1"]
		var base_pos2: Vector2 = layers["pos2"]

		# Смещаем patch в сторону, противоположную движению блока
		var offset1 = -velocity * jelly_offset_scale1
		var offset2 = -velocity * jelly_offset_scale2

		var target1 = base_pos1 + offset1
		var target2 = base_pos2 + offset2

		patch1.position = patch1.position.lerp(target1, jelly_lerp_speed * delta)
		patch2.position = patch2.position.lerp(target2, jelly_lerp_speed * delta)
		patch3.position = patch2.position
