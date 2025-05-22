extends Node

var current_level: int = 0: set = _set_current_level
var current_level_colors: Array
var is_prev_gameover: bool
var current_level_data: Array

enum BlockType {
	COMMON,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	LOCK_1,
	LOCK_2,
	LOCK_3,
	LOCK_4,
	LOCK_5,
	LIVE,
	ICE,
	ROCKET,
}

func _set_current_level(value) -> void:
	prints("set cur lvl", value)
	current_level = value


func get_random_color():
	var keys = LevelData.COLORS.keys()
	var random_index = randi() % keys.size()
	var random_key = keys[random_index]
	return LevelData.COLORS[random_key]


# TODO: протестировать
func get_color_with_type(color: int) -> Dictionary:
	var _normalized_color = color
	var block_type: BlockType = BlockType.COMMON

	# Это ключ?
	if color >= 20 and color <= 67:
		if color <= 27:
			_normalized_color = color - 10
			block_type = BlockType.KEY_1
		elif color <= 37:
			_normalized_color = color - 20
			block_type = BlockType.KEY_2
		elif color <= 47:
			_normalized_color = color - 30
			block_type = BlockType.KEY_3
		elif color <= 57:
			_normalized_color = color - 40
			block_type = BlockType.KEY_4
		else:
			_normalized_color = color - 50
			block_type = BlockType.KEY_5

	# Это замок?
	elif color >= 210 and color <= 617:
			if color <= 217:
				_normalized_color = color - 200
				block_type = BlockType.LOCK_1
			elif color <= 317:
				_normalized_color = color - 300
				block_type = BlockType.LOCK_2
			elif color <= 417:
				_normalized_color = color - 400
				block_type = BlockType.LOCK_3
			elif color <= 517:
				_normalized_color = color - 500
				block_type = BlockType.LOCK_4
			else:
				_normalized_color = color - 600
				block_type = BlockType.LOCK_5

	# Живой куб?
	elif color >= 1010 and color <= 1017:
		_normalized_color = color - 1000
		block_type = BlockType.LIVE

	# Замороженный куб
	elif color >= 2010 and color <= 2017:
		_normalized_color = color - 2000
		block_type = BlockType.ICE

	# Ракета
	elif color >= 3010 and color <= 3017:
		_normalized_color = color - 3000
		block_type = BlockType.ROCKET

	var _color: Color
	if _normalized_color > 2:
		_color = LevelData.COLORS[_normalized_color]

	return {
		"color_number": _normalized_color,
		"color": _color,
		"type": block_type
	}


func get_cell(pos: Vector2i) -> Array:
	# сначала Y потом X, так как в массиве сначала идут ряды, потом колонки

	prints("get_cell", pos)

	if pos.y < 0 or pos.y >= current_level_data.size():
		return []

	if pos.x < 0 or pos.x >= current_level_data[0].size():
		return []

	var cur_level = get_current_level()
	var result = cur_level[pos.y][pos.x]

	prints("get_cell result", pos.y, pos.x, cur_level[pos.y])
	# TODO: подумать нужно ли возвращать пустой массив
	#if result == LevelData.EMPTY_CELL:
		#return []

	return result


func get_current_level() -> Array:
	""" копия текущего уровня """
	var _cur_level = current_level
	if current_level > 200:
		_cur_level = (current_level - 200) + 50

	var level = LevelData.levels[_cur_level].duplicate(true)
	current_level_data = level

	return level


func get_non_empty_cells() -> Array:
	var result: Array

	var _cur_level_data = get_current_level()

	for y in _cur_level_data.size():
		for x in _cur_level_data[y].size():
			var _cur_cell = _cur_level_data[y][x]
			if _cur_cell != LevelData.EMPTY_CELL and _cur_cell != LevelData.FREE_CELL:
				var cell = {
					"position": Vector2i(x, y),
					"colors": _cur_cell
				}
				result.push_back(cell)

	return result


func get_current_level_colors() -> Array:
	return _level_colors(get_current_level())


func get_target_colors() -> Dictionary:
	""" цели для текущего уровня """
	return LevelData.target_by_level[current_level].duplicate(true)


func _level_colors(level: Array) -> Array:
	var _colors: Dictionary

	for i in level:
		for j in i:
			for c in j:
				var _typed_color = get_color_with_type(c)
				var _color = _typed_color.color_number
				if _color > 2:
					_colors[_color] = true

	return _colors.keys()
