extends Node

var current_level: int = 0: set = _set_current_level
var current_level_colors: Array
var is_prev_gameover: bool

func _set_current_level(value) -> void:
	prints("set cur lvl", value)
	current_level = value

func get_random_color():
	var keys = LevelData.COLORS.keys()
	var random_index = randi() % keys.size()
	var random_key = keys[random_index]
	return LevelData.COLORS[random_key]


func get_current_level() -> Array:
	prints("current_level", current_level)
	var _cur_level = current_level
	if current_level > 200:
		_cur_level = (current_level - 200) + 50

	var level = LevelData.levels[_cur_level].duplicate(true)

	return level


func get_current_level_colors() -> Array:
	return _level_colors(get_current_level())


func get_target_colors() -> Dictionary:
	return LevelData.target_by_level[current_level].duplicate(true)


func _level_colors(level: Array) -> Array:
	var _colors: Dictionary

	for i in level:
		for j in i:
			for c in j:
				if c > 0:
					_colors[c] = true

	return _colors.keys()
