class_name ColorBlock2D extends Control

var colors: Array = LevelData.FREE_CELL.duplicate(true)

enum EPlanes {
	HORIZONTAL,
	VERTICAL,
}

var can_take_block: bool = true
var follow_mouse: bool = false
var count_block = 0
var last_position := Vector2.ZERO
var is_button: bool: set = _set_is_button

var _color_node_binds: Dictionary = {}

# размеры блока в пикселях
const FULL_W = 200
const FULL_H = 200
const HALF_W = FULL_W / 2
const HALF_H = FULL_H / 2


@onready var tile_nodes: Array[ColorTile2D] = [
	$ColorTile0, $ColorTile1,
	$ColorTile2, $ColorTile3
]
@onready var debug_label: Label = $DebugLabel
@onready var button = $Button

signal pressed
signal remove


func _toggle_debug_label() -> void:
	debug_label.visible = not debug_label.visible


func _enable_debug_label(value: bool) -> void:
	if debug_label:
		debug_label.visible = value


func _ready() -> void:
	if not OS.is_debug_build():
		debug_label.visible = false

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

	for tile in tile_nodes:
		tile.velocity = velocity
		tile.is_fly = follow_mouse

	debug_label.text = str("%d  %d\n%d  %d" % colors)


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
		SFX.play_sound("cube_take")
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
	update_tiles(colors)


func set_colors(color_list: Array) -> void:
	"""
	задаёт цвета всем тайлам,
	сбрасывает размеры и положение тайлов
	"""

	_color_node_binds = {}

	const block_pos = {
		0: Vector2(0, 0),
		1: Vector2(HALF_W, 0),
		2: Vector2(0, HALF_H),
		3: Vector2(HALF_W, HALF_H),
	}

	for i in tile_nodes.size():
		var _color = color_list[i]
		var _block = tile_nodes[i]

		# сброс предыдущих манипуляций с тайлами
		_block.position = block_pos[i]
		_block.size = Vector2(HALF_W, HALF_H)
		_block.visible = true

		_block.color = _color
		_color_node_binds[_block.get_color()] = _block


func update_tiles(color_list: Array) -> void:
	""" Обновляет размеры тайлов на основе количества цветов. Без анимации """

	set_colors(color_list)

	if are_all_elements_equal(color_list):
		tile_nodes[0].visible = true
		tile_nodes[1].visible = false
		tile_nodes[2].visible = false
		tile_nodes[3].visible = false

		tile_nodes[0].size = Vector2(FULL_W, FULL_H)
		_color_node_binds[color_list[0]] = tile_nodes[0]
		count_block = 1

	else:
		# один цвет сверху
		if color_list[0] == color_list[1]:
			tile_nodes[0].visible = true
			tile_nodes[1].visible = false
			tile_nodes[0].size = Vector2(FULL_W, HALF_H)
			_color_node_binds[color_list[0]] = tile_nodes[0]

		# один цвет снизу
		if color_list[2] == color_list[3]:
			tile_nodes[2].visible = true
			tile_nodes[3].visible = false
			tile_nodes[2].size = Vector2(FULL_W, HALF_H)
			_color_node_binds[color_list[2]] = tile_nodes[2]

		# один цвет слева
		if color_list[0] == color_list[2]:
			tile_nodes[0].visible = true
			tile_nodes[2].visible = false
			tile_nodes[0].size = Vector2(HALF_W, FULL_H)
			_color_node_binds[color_list[0]] = tile_nodes[0]

		# один цвет справа
		if color_list[1] == color_list[3]:
			tile_nodes[1].visible = true
			tile_nodes[3].visible = false
			tile_nodes[1].size = Vector2(HALF_W, FULL_H)
			_color_node_binds[color_list[1]] = tile_nodes[1]


func remove_block() -> void:
	remove.emit()
	self.get_parent().free_block()
	self.queue_free()


func fill_colors(fill_directions: Dictionary, immediate:bool = false) -> Tween:
	"""
	Анимированно расширяет блоки.
	fill_directions - данные из ColorBlock.get_fill_direction(side)
	"""

	if not fill_directions.keys().size():
		# когда последний цвет удалён

		if Utils.uniq_array(colors).size() == 1 and colors[0] == 0:
			remove_block()

		return

	var _t: Tween = create_tween().set_parallel()
	_t.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	var tween_time = 0.4
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

	for move_from in fill_directions.keys():
		var move_to = fill_directions[move_from]

		tile_nodes[move_to].hide()

		var _plane = planes[move_from][move_to]
		var animated_block = tile_nodes[move_from]

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


func get_color_tile_node(color: int) -> Node:
	""" Возвращает ноду цвета """

	var _color_node = _color_node_binds[color]

	var _node = _color_node.duplicate()
	_node.position = global_position
	return _node
