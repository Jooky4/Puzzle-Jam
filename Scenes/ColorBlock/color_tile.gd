extends Control

@export var color: Color: set = _set_color

@export var jelly_lerp_speed: float = 8.0
@export var jelly_offset_scale1: float = 0.5
@export var jelly_offset_scale2: float = 0.3


var velocity: Vector2
var is_fly: bool = false

var layers: Dictionary

func _set_color(value: Color) -> void:
	var child_list = get_children()

	child_list[0].modulate = value.darkened(0.3)
	child_list[1].modulate = value.darkened(0.3)
	child_list[2].modulate = value


func _ready() -> void:
	var children = get_children()
	layers = {
		"patch1": children[1],
		"patch2": children[2],
		"patch3": children[3],
		"pos1": children[1].position,
		"pos2": children[2].position
	}


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
