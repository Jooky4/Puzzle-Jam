extends Control

@export var texture_list: Array[Texture2D]
@export var jelly_lerp_speed: float = 8.0
@export var jelly_offset_scale1: float = 0.5
@export var jelly_offset_scale2: float = 0.3


@onready var arr_blocs = [$Small_block_1, $Small_block_2, $Small_block_3, $Small_block_4]
@onready var colors: Array = LevelData.FREE_CELL.duplicate(true)
@onready var debug_label: Label = $DebugLabel

@onready var can_take_block: bool = true
@onready var follow_mouse: bool = false
@onready var button = $Button

@onready var texture_binds = {
	10: texture_list[0],
	11: texture_list[1],
	12: texture_list[2],
	13: texture_list[3],
	14: texture_list[4],
	15: texture_list[5],
	16: texture_list[6],
	17: texture_list[7],
}

var count_block = 0
var last_position := Vector2.ZERO
var jelly_layers: Array = []


func _collect_jelly_layers():
	for control in arr_blocs:
		var children = control.get_children()
		if children.size() >= 2:
			# сохраняем: control, patch1, patch2, их локальные позиции
			jelly_layers.append({
				"control": control,
				"patch1": children[1],
				"patch2": children[2],
				"patch3": children[3],
				"pos1": children[1].position,
				"pos2": children[2].position
			})


func get_all_nine_patches(control: Control) -> Array:
	var result = []
	for child in control.get_children():
		if child is NinePatchRect:
			result.append(child)
	return result


func _ready() -> void:
	if not OS.is_debug_build():
		debug_label.visible = false
	_collect_jelly_layers()
	last_position = global_position


func _to_string() -> String:
	return "<Block: %s colors: [%s]>" % [
			name,
			colors
		]


func _process(delta):
	if follow_mouse:
		global_position = get_global_mouse_position() - Vector2(52.5, 52.5)

	# Вычисляем скорость движения блока
	var velocity = global_position - last_position
	last_position = global_position

	# Обновляем желейные слои
	for layer in jelly_layers:
		var control = layer["control"]
		var patch1 = layer["patch1"]
		var patch2 = layer["patch2"]
		var patch3 = layer["patch3"]
		var base_pos1: Vector2 = layer["pos1"]
		var base_pos2: Vector2 = layer["pos2"]

		# Смещаем patch в сторону, противоположную движению блока
		var offset1 = -velocity * jelly_offset_scale1
		var offset2 = -velocity * jelly_offset_scale2

		var target1 = base_pos1 + offset1
		var target2 = base_pos2 + offset2

		patch1.position = patch1.position.lerp(target1, jelly_lerp_speed * delta)
		patch2.position = patch2.position.lerp(target2, jelly_lerp_speed * delta)
		patch3.position = patch2.position

	debug_label.text = str("[%d, %d,\n%d, %d]" % colors)


func get_color_block(arr_color) -> void:
	can_take_block = false
	button.visible = false
	colors = arr_color

	#$Small_block_1/ColorRect.color = LevelData.COLORS[arr_color[0]]
	#$Small_block_2/ColorRect.color = LevelData.COLORS[arr_color[1]]
	#$Small_block_3/ColorRect.color = LevelData.COLORS[arr_color[2]]
	#$Small_block_4/ColorRect.color = LevelData.COLORS[arr_color[3]]

	prints("arr_color", arr_color)
	for i in arr_blocs.size():
		var nine_patches = get_all_nine_patches(arr_blocs[i])

		var color = LevelData.COLORS[arr_color[i]]
		for patch in nine_patches:
			patch.modulate = color
			#patch.texture = #texture_binds[arr_color[i]]

	set_reate_compain(colors)
	#update_ui()


func drop_block() -> void:
	can_take_block = false
	follow_mouse = false
	button.visible = false


func are_all_elements_equal(arr: Array) -> bool:
	var first_element = arr[0]
	for element in arr:
		if element != first_element:
			return false
	return true


func _on_button_button_down() -> void:
	if can_take_block:
		z_index = 10
		follow_mouse = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func button_up() -> void:
	follow_mouse = false
	z_index = 0
	button.mouse_filter = Control.MOUSE_FILTER_PASS


func _fix_diagonal_colors(colors: Array) -> void:
	"""
	var example = [
		0, 1,
		1, 0
	]
	var example_result = [
		0, 0,
		1, 1
	]
	"""

	if colors[0] == colors[3]:
		var color1 = colors[0]
		var color2 = colors[1]
		colors[0] = color2
		colors[1] = color1

	if colors[1] == colors[2]:
		var color1 = colors[1]
		var color2 = colors[3]
		colors[1] = color2
		colors[3] = color1


func _create_random_color(used_colors: Array) -> Array:
	var chance_percent = randi_range(1, 100)
	var colors: Array

	used_colors.shuffle()

	if chance_percent <= 10:
		# один цвет
		var color = used_colors.pick_random()
		colors = [color, color, color, color]
	elif chance_percent > 15 and chance_percent <= 10 + 15:
		# два цвета
		colors = used_colors.slice(0, 2)
		colors.append_array(colors)
		colors.shuffle()
		_fix_diagonal_colors(colors)
	elif chance_percent > 10 + 15 and chance_percent <= 10 + 15 + 45:
		# три цвета
		colors = used_colors.slice(0, 3)
		var add_color = colors.pick_random()
		colors.push_back(add_color)
		colors.shuffle()
		_fix_diagonal_colors(colors)
	else:
		# четыре цвета
		colors = used_colors.slice(0, 4)
		# по идее, здесь не нужно. Все цвета уникальные
		# TODO: проверить
		_fix_diagonal_colors(colors)

	return colors


func create_random_color(used_colors: Array = []) -> void:
	if used_colors.size() == 0:
		used_colors = LevelManager.get_current_level_colors()

	var data = _create_random_color(used_colors)
	colors = data

	set_reate_compain(colors)
	#update_ui()


func update_ui() -> void:
	# будущая замена set_reate_compain()
	var tails = [
		$Small_block_1/ColorRect,
		$Small_block_2/ColorRect,
		$Small_block_3/ColorRect,
		$Small_block_4/ColorRect,
	]

	for i in colors.size():
		var color = colors[i]
		var current_tail = tails[i]

		if color == 0:
			current_tail.color = Color.WHITE
			continue

		current_tail.color = LevelData.COLORS[color]


func set_reate_compain(arr_color) -> void:
	for i in arr_blocs.size():
		var nine_patches = get_all_nine_patches(arr_blocs[i])
		var color = LevelData.COLORS[arr_color[i]]

		var child_list = arr_blocs[i].get_children()
		child_list[0].modulate = color.darkened(0.3)
		child_list[1].modulate = color.darkened(0.3)
		child_list[2].modulate = color

	var full_w = 200
	var full_h = 200

	var half_w = 100
	var half_h = 100

	if are_all_elements_equal(arr_color):
		arr_blocs[0].visible = true
		arr_blocs[1].visible = false
		arr_blocs[2].visible = false
		arr_blocs[3].visible = false
		#create_tween().tween_property(
			#arr_blocs[0],
			#"custom_minimum_size",
			#Vector2(105, 105),
			#1
		#)
		arr_blocs[0].size = Vector2(full_w, full_h)
		count_block = 1

	else:
		if arr_color[0] == arr_color[1]:
			arr_blocs[0].visible = true
			arr_blocs[1].visible = false
			#create_tween().tween_property(arr_blocs[0], "custom_minimum_size", Vector2(105, 50), 1)
			arr_blocs[0].size = Vector2(full_w, half_h)

		if arr_color[2] == arr_color[3]:
			arr_blocs[2].visible = true
			arr_blocs[3].visible = false
			#create_tween().tween_property(arr_blocs[2], "custom_minimum_size", Vector2(105, 50), 1)
			arr_blocs[2].size = Vector2(full_w, half_h)

		if arr_color[0] == arr_color[2]:
			arr_blocs[0].visible = true
			arr_blocs[2].visible = false
			#create_tween().tween_property(arr_blocs[0], "custom_minimum_size", Vector2(50, 105), 1)
			arr_blocs[0].size = Vector2(half_w, full_h)

		if arr_color[1] == arr_color[3]:
			arr_blocs[1].visible = true
			arr_blocs[3].visible = false
			#create_tween().tween_property(arr_blocs[1], "custom_minimum_size", Vector2(50, 105), 1)
			arr_blocs[1].size = Vector2(half_w, full_h)

		var unique_dict = {}
		for color in arr_color:
			unique_dict[color] = true
		count_block = unique_dict.keys().size()

		if arr_blocs[0].visible and arr_blocs[1].visible and arr_blocs[2].visible and arr_blocs[3].visible:
			count_block = 4


func update_block(delete_color, direction) -> void:
	for i in range(colors.size()):
		if colors[i] == 0:
			if count_block == 1:
				colors = LevelData.FREE_CELL
				self.get_parent().free_block()
				self.queue_free()
				return

			elif count_block == 2:
				for k in colors:
					if colors.count(k) == 2:
						colors = [k, k, k, k]
						break
				break

			elif count_block == 3:
				for j in range(colors.size()):
					if colors[j] == delete_color:
						colors[j] = 0

				if colors[0] == 0 and colors[3] == 0:
					colors[0] = colors[1]
					colors[3] = colors[2]
				elif colors[1] == 0 and colors[2] == 0:
					colors[1] = colors[0]
					colors[2] = colors[3]
				elif colors[0] == 0 and colors[2] == 0:
					colors[0] = colors[1]
					colors[2] = colors[3]
				elif colors[1] == 0 and colors[3] == 0:
					colors[1] = colors[0]
					colors[3] = colors[2]
				elif colors[0] == 0 and colors[1] == 0:
					colors[0] = colors[2]
					colors[1] = colors[3]
				elif colors[1] == 0 and colors[2] == 0:
					colors[1] = colors[0]
					colors[2] = colors[3]
				elif colors[2] == 0 and colors[3] == 0:
					colors[2] = colors[0]
					colors[3] = colors[1]
				else:
					for k in range(colors.size()):
						if colors.count(colors[k]) == 1 and colors[k] != 0:
							colors[i] = colors[k]
							break
				break

			elif count_block == 4:
				if i == 0:
					if direction == "up":
						colors[i] = colors[2]
					elif direction == "left":
						colors[i] = colors[1]
				elif i == 1:
					if direction == "up":
						colors[i] = colors[3]
					elif direction == "right":
						colors[i] = colors[0]
				elif i == 2:
					if direction == "down":
						colors[i] = colors[0]
					elif direction == "left":
						colors[i] = colors[3]
				elif i == 3:
					if direction == "down":
						colors[i] = colors[1]
					elif direction == "right":
						colors[i] = colors[2]
				break

	#update_ui()
	set_reate_compain(colors)
