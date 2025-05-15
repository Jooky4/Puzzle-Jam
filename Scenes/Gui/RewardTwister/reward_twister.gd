extends Control


@export var iteration_time: float = 1
@export var base_value: int = 100
@export var multiplier_list: Array[int]

@onready var arrow: TextureRect = $Arrow
@onready var label: Label = $TextureButton/Label


var _tween: Tween

signal reward(value: int)


func _ready() -> void:
	arrow.rotation = deg_to_rad(-90)
	_rotate()


func _process(delta: float) -> void:
	if label:
		label.text = "+" + str(current_reward())


func current_reward() -> int:
	var segment = _find_segment(_current_degree())
	var reward = _reward_value(segment)
	return reward


func _reward_value(segment) -> int:
	var multiplier = multiplier_list[segment-1]
	return multiplier * base_value


func _find_segment(value) -> int:
	var segment_count = multiplier_list.size()
	var segment_length = 180 / segment_count
	if value == 180:
		return segment_count

	return (value / segment_length) + 1


func _rotate() -> void:
	_tween = create_tween()
	_tween.tween_property(arrow, "rotation", deg_to_rad(90), iteration_time)
	_tween.chain()
	_tween.tween_property(arrow, "rotation", deg_to_rad(-90), iteration_time)
	_tween.set_loops(100)
	_tween.play()


func _current_degree() -> float:
	return rad_to_deg(arrow.rotation) + 90


func _on_texture_button_pressed() -> void:
	_tween.stop()
	reward.emit(current_reward())
