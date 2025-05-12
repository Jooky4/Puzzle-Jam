extends Node

var current_level: int = 0: set = _set_current_level
var current_level_colors: Array
var is_prev_gameover: bool
var current_level_data: Array

func _set_current_level(value) -> void:
	prints("set cur lvl", value)
	current_level = value


func get_random_color():
	var keys = LevelData.COLORS.keys()
	var random_index = randi() % keys.size()
	var random_key = keys[random_index]
	return LevelData.COLORS[random_key]


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
				if c > 0:
					_colors[c] = true

	return _colors.keys()
