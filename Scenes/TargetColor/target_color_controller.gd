extends HBoxContainer

@export var target_color: PackedScene

var colors: Dictionary


func set_colors(value: Dictionary) -> void:
	colors = value
	_create_ui()


func _create_ui() -> void:
	for i in get_children():
		remove_child(i)

	for c in colors.keys():
		var color_block = target_color.instantiate()
		add_child(color_block)
		color_block.set_count(colors[c])
		var color = c
		color_block.set_color(color)


func _update_ui() -> void:
	for i in get_children():
		var count = colors[i.color]
		i.set_count(count)


func dec_color(color: int) -> void:
	if color in colors.keys():
		var count = colors[color]
		colors[color] = max(0, count - 1)

		_update_ui()


func get_colors_count() -> int:
	var result: int
	for k in colors.keys():
		result += colors[k]

	return result


func is_colors_left() -> bool:
	return get_colors_count() > 0
