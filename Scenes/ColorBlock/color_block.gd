extends Control

@export var jelly_lerp_speed: float = 8.0
@export var jelly_offset_scale1: float = 0.5
@export var jelly_offset_scale2: float = 0.3


@onready var arr_blocs = [$Small_block_1, $Small_block_2, $Small_block_3, $Small_block_4]
@onready var debug_label: Label = $DebugLabel
@onready var button = $Button

var colors: Array = LevelData.FREE_CELL.duplicate(true)

enum EPlanes {
	HORIZONTAL,
	VERTICAL,
}

var can_take_block: bool = true
var follow_mouse: bool = false
var count_block = 0
var last_position := Vector2.ZERO
var jelly_layers: Array = []
var is_button: bool: set = _set_is_button

var _color_node_binds: Dictionary = {}

signal pressed
signal remove


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
	return "<Block: %s colors: [%s]>" % [name, colors]


func set_is_button(value: bool) -> void:
	is_button = value


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

	for i in arr_blocs.size():
		var nine_patches = get_all_nine_patches(arr_blocs[i])

		#var color = LevelData.COLORS[arr_color[i]]
		var color_data = LevelManager.get_color_with_type(arr_color[i])
		# Назначаем цвет кроме последнего. Последний это блик
		for patch_idx in nine_patches.size()-1:
			var _patch = nine_patches[patch_idx]
			_patch.modulate = color_data.color

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
	if is_button:
		pressed.emit(self)
		return

	if can_take_block:
		z_index = 10
		follow_mouse = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_is_button(value: bool) -> void:
	is_button = value
	if button:
		var _cur_mouse_filter = button.mouse_filter
		button.visible = is_button
		if is_button:
			button.mouse_filter = Control.MOUSE_FILTER_PASS
		else:
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

	# для тестов
	#colors = [
		#[10, 11, 10, 11],
		#[10, 10, 11, 11],
	#].pick_random()

	set_reate_compain(colors)


func update_ui() -> void:
	# будущая замена set_reate_compain()

	for i in colors.size():
		var color = colors[i]
		var current_tail = arr_blocs[i]

		if color == 0:
			_set_color(current_tail, Color.WHITE)
		else:
			_set_color(current_tail, LevelData.COLORS[color])


func _set_color(tile: Node, color: Color) -> void:
	var child_list = tile.get_children()

	child_list[0].modulate = color.darkened(0.3)
	child_list[1].modulate = color.darkened(0.3)
	child_list[2].modulate = color


func set_reate_compain(arr_color) -> void:
	for i in arr_blocs.size():
		var nine_patches = get_all_nine_patches(arr_blocs[i])
		if arr_color[i] == 0:
			break

		var _color_data = LevelManager.get_color_with_type(arr_color[i])
		_set_color(arr_blocs[i], _color_data.color)

	var full_w = 200
	var full_h = 200

	var half_w = 100
	var half_h = 100

	for i in arr_color.size():
		var _color = arr_color[i]
		var _block = arr_blocs[i]
		_color_node_binds[_color] = _block

	if are_all_elements_equal(arr_color):
		arr_blocs[0].visible = true
		arr_blocs[1].visible = false
		arr_blocs[2].visible = false
		arr_blocs[3].visible = false

		arr_blocs[0].size = Vector2(full_w, full_h)
		_color_node_binds[arr_color[0]] = arr_blocs[0]
		count_block = 1

	else:
		if arr_color[0] == arr_color[1]:
			arr_blocs[0].visible = true
			arr_blocs[1].visible = false
			arr_blocs[0].size = Vector2(full_w, half_h)
			_color_node_binds[arr_color[0]] = arr_blocs[0]

		if arr_color[2] == arr_color[3]:
			arr_blocs[2].visible = true
			arr_blocs[3].visible = false
			arr_blocs[2].size = Vector2(full_w, half_h)
			_color_node_binds[arr_color[2]] = arr_blocs[2]

		if arr_color[0] == arr_color[2]:
			arr_blocs[0].visible = true
			arr_blocs[2].visible = false
			arr_blocs[0].size = Vector2(half_w, full_h)
			_color_node_binds[arr_color[0]] = arr_blocs[0]

		if arr_color[1] == arr_color[3]:
			arr_blocs[1].visible = true
			arr_blocs[3].visible = false
			arr_blocs[1].size = Vector2(half_w, full_h)
			_color_node_binds[arr_color[1]] = arr_blocs[1]

		var unique_dict = {}
		for color in arr_color:
			unique_dict[color] = true
		count_block = unique_dict.keys().size()

		if arr_blocs[0].visible and arr_blocs[1].visible and arr_blocs[2].visible and arr_blocs[3].visible:
			for i in arr_color.size():
				var _color = arr_color[i]

			count_block = 4

		for i in arr_color.size():
			var _color = arr_color[i]
			var _block = arr_blocs[i]

			var _is_same_block = _color_node_binds[_color] == _block
			if _is_same_block and not _block.visible:
				_color_node_binds.erase(_color)


func remove_block() -> void:
	remove.emit()
	self.get_parent().free_block()
	self.queue_free()


func new_update_block(move: Dictionary) -> void:
	if colors == LevelData.FREE_CELL:
		prints("is free cell")
		remove_block()
		return

	for k in move.keys():
		var tile


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


func fill_colors(fill_directions: Dictionary, immediate:bool = false) -> Tween:
	"""
	Анимированно расширяет блоки.
	fill_directions - данные из ColorBlock.get_fill_direction(side)
	"""

	var _t: Tween = create_tween().set_parallel()
	_t.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	var tween_time = 0.5
	if immediate:
		tween_time = 0

	var full_w = 200
	var full_h = 200

	var planes = {
		0: {
			1: EPlanes.HORIZONTAL,
			2: EPlanes.VERTICAL,
		},
		1: {
			0: EPlanes.HORIZONTAL,
			3: EPlanes.VERTICAL,
		},
		2: {
			3: EPlanes.HORIZONTAL,
			0: EPlanes.VERTICAL,
		},
		3: {
			2: EPlanes.HORIZONTAL,
			1: EPlanes.VERTICAL,
		},
	}

	var color_tiles = arr_blocs

	for move_from in fill_directions.keys():
		var move_to = fill_directions[move_from]

		color_tiles[move_to].hide()

		var _plane = planes[move_from][move_to]
		var animated_block = color_tiles[move_from]

		if not animated_block.visible:
			continue

		if _plane == EPlanes.HORIZONTAL:
			_t.tween_property(animated_block, "size:x", full_w, tween_time)
			if animated_block.position.x > 0:
				_t.tween_property(animated_block, "position:x", 0, tween_time)
		else:
			_t.tween_property(animated_block, "size:y", full_h, tween_time)
			if animated_block.position.y > 0:
				_t.tween_property(animated_block, "position:y", 0, tween_time)

	if Utils.uniq_array(colors).size() == 1 and colors[0] == 0:
		remove_block()

	_t.play()
	return _t


func _get_color_node(color: int) -> Node:
	return Node.new()


func get_color_tile_node(color: int) -> Node:
	""" Возвращает ноду цвета """

	var _color_node = _color_node_binds[color]

	var _node = _color_node.duplicate()
	#_node.color = LevelManager.get_color_with_type(color).color
	#_node.size = _color_node.size / 2
	_node.position = global_position
	return _node
