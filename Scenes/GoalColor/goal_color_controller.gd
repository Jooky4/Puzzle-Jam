@tool
extends Control

@export var goal_color: PackedScene

@onready var container: HBoxContainer = %Colors

var colors: Dictionary


func set_colors(value: Dictionary) -> void:
	colors = value

	_create_ui()


func _create_ui() -> void:
	for i in container.get_children():
		container.remove_child(i)

	for c in colors.keys():
		var color_block = goal_color.instantiate()
		container.add_child(color_block)
		color_block.set_count(colors[c])
		var color = c
		color_block.set_color(color)


func _update_ui() -> void:
	for i in container.get_children():
		var count = colors[i.color]
		i.set_count(count)


func dec_color(color: int, count: int = 2) -> void:
	if color in colors.keys():
		var new_count = colors[color]
		colors[color] = max(0, new_count - count)

		SFX.play_sound("target_1")
		_update_ui()


func get_colors_count() -> int:
	var result: int
	for k in colors.keys():
		result += colors[k]

	return result


func has_items() -> bool:
	return get_colors_count() > 0
