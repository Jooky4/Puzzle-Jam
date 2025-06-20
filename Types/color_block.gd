class_name ColorBlock extends Resource

"""
Терминология

блок - это квадрат с цветными тайлами. Тайлов всегда 4

тайл - это углы блока. Абстрактное понятие.
	Тайл 0 это верхний левый квадрат блока
	1 - верхний правый
	2 - нижний левый
	3 - нижний правый

цвет - это номер цвета тайла. Хранятся в colors. Список основных цветов в LevelData.COLORS
side - сторона блока (верхняя сторона, левая сторона и т.д.)
"""

"""
colors - содержит оригинальные значения цвета, как записано в уровне.
Напр. [2013, 1010, 12, 10]
"""
@export var colors: Array
@export var position: Vector2i

const DEBUG = true
const FREE_TILE_COLOR = 0

var is_vertical: bool

enum ESides {
	TOP,
	RIGHT,
	BOTTOM,
	LEFT,
}

# Относительные координаты сторон блока
const SIDE_POSITION = {
	ESides.TOP: Vector2i(0, -1),
	ESides.RIGHT: Vector2i(1, 0),
	ESides.BOTTOM: Vector2i(0, 1),
	ESides.LEFT: Vector2i(-1, 0),
}

const tiles = [0, 1, 2, 3]

const REVERSE_SIDE = {
	ESides.TOP: ESides.BOTTOM,
	ESides.BOTTOM: ESides.TOP,
	ESides.RIGHT: ESides.LEFT,
	ESides.LEFT: ESides.RIGHT,
}

"""
	индексы тайлов с противоположной стороны блока
	например:
	Берём верхний левый тайл, если смотреть сверху (ESides.TOP),
	то противоположный будет 2
	Код будет: ANOTHER_SIDES[ESides.TOP][0] -> 2
"""
const ANOTHER_SIDES = {
	ESides.TOP: {
		0: 2,
		1: 3,
	},
	ESides.RIGHT: {
		1: 0,
		3: 2,
	},
	ESides.BOTTOM: {
		2: 0,
		3: 1,
	},
	ESides.LEFT: {
		0: 1,
		2: 3
	}
}

const TILE_INDEXES_BY_SIDE = {
	ESides.TOP: [0, 1],
	ESides.RIGHT: [1, 3],
	ESides.BOTTOM: [2, 3],
	ESides.LEFT: [0, 2]
}

# направления в которые "смотрит" одиночный тайл
const ONE_TILE_DIRECTIONS = {
	0: [ESides.TOP, ESides.LEFT],
	1: [ESides.TOP, ESides.RIGHT],
	2: [ESides.BOTTOM, ESides.LEFT],
	3: [ESides.BOTTOM, ESides.RIGHT],
}


func _to_string() -> String:
	return "<ColorBlock x:%d; y:%d; c:%s>" % [position.x, position.y, colors]


func _get_side_colors(_colors: Array, side: ESides) -> Array:
	var idx = TILE_INDEXES_BY_SIDE[side]
	var color1 = idx[0]
	var color2 = idx[1]
	var _c1_with_type = ColorTile.create_from_color(_colors[color1])
	var _c2_with_type = ColorTile.create_from_color(_colors[color2])

	return [
		#_colors[color1],
		#_colors[color2]
		_c1_with_type.color,
		_c2_with_type.color
	]


func get_side_colors(side: ESides) -> Array:
	""" Возвращает цвета с указанной стороны """

	# Цвета с указанной стороны
	return _get_side_colors(colors, side)


func is_free() -> bool:
	""" проверяет пустой блок или нет"""
	var _uniq_colors = Utils.uniq_array(colors)
	return _uniq_colors.size() == 1 and _uniq_colors[0] == FREE_TILE_COLOR


func is_side_colors_equal(side: ESides) -> bool:
	""" Проверяет с указанной стороны оба тайла одного цвета """

	var side_colors = get_side_colors(side)
	return side_colors[0] == side_colors[1]


func get_side_tiles(side: ESides) -> Array:
	return TILE_INDEXES_BY_SIDE[side]


func get_unique_colors() -> Array:
	var result: Dictionary

	for i in colors:
		result[i] = true

	return result.keys()


func get_colors_count() -> Dictionary:
	"""
	Возвращает Количество цветов в формате:
		{ LevelData.COLORS: int }

		Пример:
		{
			10: 1, # голубой 1 плитка
			11: 2, # фиолетовый 2 плитки
			12: 1, # синий 1 плитка
		}
	"""

	var result: Dictionary

	for i in colors:
		if i in result.keys():
			result[i] = result[i] + 1
		else:
			result[i] = 1

	return result


func get_side_by_tiles(tile1: int, tile2: int) -> ESides:
	""" Возвращает сторону по индексам тайлов"""

	for i in TILE_INDEXES_BY_SIDE.keys():
		var tiles = TILE_INDEXES_BY_SIDE[i]
		if tiles[0] == tile1 and tiles[1] == tile2 or\
			tiles[0] == tile2 and tiles[1] == tile1:
				return i

	return -1


func get_another_side_tile(tile_index: int, side: ESides) -> int:
	"""
	Возвращает индекс тайла с противоположной стороны

	Пример:
		плитки [
			0, 1,
			2, 3
		]

		get_another_side_tile(0, TOP) -> 2
		get_another_side_tile(0, LEFT) -> 1

		Возвращает индекс -1 если tile_index нет на side стороне

		get_another_side_tile(0, RIGHT) -> -1
		get_another_side_tile(0, BOTTOM) -> -1
	"""

	var _another_side = ANOTHER_SIDES[side]
	if tile_index not in _another_side:
		return -1

	return ANOTHER_SIDES[side][tile_index]


func _fill(fill_direction: Dictionary) -> void:
	""" Заполняет цвета по направлениям из get_fill_direction()"""
	for move_from in fill_direction.keys():
		var move_to = fill_direction[move_from]
		colors[move_to] = colors[move_from]


func autofill(side: ESides) -> void:
	_fill(get_fill_direction(side))


func get_fill_direction(side: ESides) -> Dictionary:
	"""
	Заполнение пустых тайлов цветом

	Использует список цветов с пустыми тайлами и сторону (side)

	Возвращает словарь, где
		ключ - индекс откуда берём цвет
		значение - индекс куда заливаем цвет

	Индексы тайлов всегда:
	[
		0, 1,
		2, 3,
	]

	Примеры:
		№1
		_colors: [0, 0, 10, 10]
		side: TOP

		результат:
		{
			# откуда: куда
			2: 0,
			3: 1
		}

		№2
		_colors: [0, 10, 11, 12]
		side: TOP

		результат: { 2: 0 }
	"""

	var result: Dictionary

	# нет пустых тайлов c указанной стороны, ничего заполнять не нужно
	if FREE_TILE_COLOR not in _get_side_colors(colors, side):
		return {}

	var _uniq_colors = Utils.uniq_array(colors)

	match _uniq_colors.size():
		1:
			if DEBUG:
				prints("пустой блок, нечего перемещать")
			result = {}
		2:
			if DEBUG:
				prints("Заполняем всё оставшимся цветом")
			var _side: ESides

			# удаляем пустые тайлы, остаётся единственный цвет
			_uniq_colors.erase(FREE_TILE_COLOR)
			var the_only_color = _uniq_colors[0]

			var _color_tile_indexes = []

			# Не важно значение side, ищем сторону на которой единственный цвет
			for i in colors.size():
				var _color = colors[i]

				if _color == the_only_color:
					_color_tile_indexes.push_back(i)

			# узнаём на какой стороне цветные блоки
			_side = get_side_by_tiles(_color_tile_indexes[0], _color_tile_indexes[1])

			# заполнение будет от цвета на противоположную сторону
			for tile in get_side_tiles(_side):
				var another_side_tile = get_another_side_tile(tile, _side)
				result[tile] = another_side_tile

		3:
			if DEBUG:
				prints("fill 3 colors")
			var side_tile_indexes = get_side_tiles(side)
			var _color_count = get_colors_count()

			# с указанной стороны нет пустых тайлов
			if FREE_TILE_COLOR not in get_side_colors(side):
				prints(0)
				return {}

			if _color_count[FREE_TILE_COLOR] == 2:
				if DEBUG:
					prints("две пустых ячейки")
				_uniq_colors.erase(FREE_TILE_COLOR)
				var color1 = _uniq_colors[0]
				var color2 = _uniq_colors[1]
				var _color1_tile = colors.find(color1)
				var _color2_tile = colors.find(color2)

				var _side = get_side_by_tiles(_color1_tile, _color2_tile)

				result[_color1_tile] = get_another_side_tile(_color1_tile, _side)
				result[_color2_tile] = get_another_side_tile(_color2_tile, _side)

			else:
				""" ищем цвет, занимающий одну ячейку и перемещаем в пустую """

				if DEBUG:
					prints("одна пустая ячейка")

				var the_signle_tile_index: int

				for i in colors.size():
					var _color = colors[i]
					if _color != FREE_TILE_COLOR and _color_count[_color] == 1:
						the_signle_tile_index = i
						break

				var free_tile_index = colors.find(FREE_TILE_COLOR)
				result[the_signle_tile_index] = free_tile_index

		4:
			if DEBUG:
				prints("fill 4 colors")
			var color_index = colors.find(FREE_TILE_COLOR)
			var another_color_index = get_another_side_tile(color_index, side)
			result = {
				another_color_index: color_index
			}

	return result


func _remove_color(color, side: ESides) -> Array:
	"""
	заменяем удаляемый цвет нулями, если обнаружено совпадение
	"""

	prints("_remove_color", colors, color, side)
	var unique_colors = get_unique_colors()
	var color_count = get_colors_count()

	var result: Array = colors.duplicate()

	match unique_colors.size():
		1:
			if DEBUG:
				prints("один цвет", unique_colors, colors)
			if color == colors[0]:
				result = [
					FREE_TILE_COLOR,
					FREE_TILE_COLOR,
					FREE_TILE_COLOR,
					FREE_TILE_COLOR
				]
		2:
			if DEBUG:
				prints("два цвета", unique_colors, colors)
			var _side_colors = get_side_colors(side)
			var _unique_side_colors = Utils.uniq_array(_side_colors)

			if color in _side_colors:
				for i in result.size():
					var cur_color = result[i]
					if cur_color == color:
						result[i] = FREE_TILE_COLOR
		3:
			if DEBUG:
				prints("три цвета", unique_colors, colors)

			var side_colors = get_side_colors(side)
			var side_tile_indexes = get_side_tiles(side)

			# с указанной стороны нет совпадений
			if color not in side_colors:
				return colors

			# если с указанной стороны цвета одинаковые и совпадают с удаляемым цветом
			if side_colors[0] == side_colors[1] and side_colors[0] == color:
				if DEBUG:
					prints("this side has same colors")
				# копируем цвета с противоположной стороны
				result[side_tile_indexes[0]] = FREE_TILE_COLOR
				result[side_tile_indexes[1]] = FREE_TILE_COLOR

			# на стороне цвета разные
			else:
				if DEBUG:
					prints("not same colors in side")

				# ищем удаляемый цвет
				var tile_to_remove: int
				var tile_to_stay: int

				for i in side_tile_indexes:
					var ct = ColorTile.create_from_color(colors[i])
					if color == ct.color:
						tile_to_remove = i
					else:
						tile_to_stay = i

				prints("tile to remove", color, colors, tile_to_remove, tile_to_stay)

				# если удаляемый цвет занимает две клетки (в глубину)
				if color_count[colors[tile_to_remove]] > 1:
					if DEBUG:
						prints("2 cell in deep")
					var tile_to_remove2 = get_another_side_tile(tile_to_remove, side)
					var _side = get_side_by_tiles(tile_to_remove, tile_to_remove2)

					# с удаляемой стороны по порядку
					var front_tiles = get_side_tiles(_side)

					result[front_tiles[0]] = FREE_TILE_COLOR
					result[front_tiles[1]] = FREE_TILE_COLOR
				else:
					if DEBUG:
						prints("not 2 cell in deep")
					result[tile_to_remove] = FREE_TILE_COLOR
		4:
			if DEBUG:
				prints("четыре цвета", unique_colors, colors)

			var color_index = colors.find(color)

			var another_color_index = get_another_side_tile(color_index, side)
			if another_color_index < 0:
				result = colors
			else:
				result[color_index] = FREE_TILE_COLOR

	prints("result", result)
	return result


func remove_color(color, side: ESides) -> Dictionary:
	colors = _remove_color(color, side)

	return get_fill_direction(side)


func _tile_sides(tile_index: int) -> Array:
	""" возвращает список сторон в которые "смотрит" этот тайл """
	var result: Array

	# если весь блок имеет один цвет, тайл "смотрит" во все стороны
	if get_unique_colors().size() == 1:
		if DEBUG:
			prints("цвет занимает весь блок")
		return [ESides.TOP, ESides.RIGHT, ESides.BOTTOM, ESides.LEFT]

	var tile_color = colors[tile_index]

	# если цвет занимает два тайла (в т.ч. указанный тайл)
	if get_colors_count()[tile_color] == 2:
		if DEBUG:
			prints("тайл занимает два блока")
		for side in TILE_INDEXES_BY_SIDE.keys():
			var _side_tiles = TILE_INDEXES_BY_SIDE[side]

			# искомый цвет с этой стороны
			var is_color_on_side = tile_color in get_side_colors(side)

			if is_color_on_side:
				result.push_back(side)

	# цвет тайла занимает один тайл
	elif get_colors_count()[tile_color] == 1:
		result = ONE_TILE_DIRECTIONS[tile_index]

	return result


func get_tile_sides_positions(tile_index: int) -> Array[Vector2i]:
	""" Возвращает координаты блоков на карте, куда "смотрит" указанный тайл"""
	var data = _tile_sides(tile_index)
	var result: Array[Vector2i]
	for i in data:
		result.push_back(_side_position(i))

	return result


func _side_position(side: ESides) -> Vector2i:
	"""
	Возвращает позицию на уровне от _этого_ блока в указанную сторону

	ВАЖНО: перед использованием метода, указать position _этого_ блока
	"""

	Vector2i(2, 3) * Vector2i(2, 3)
	return position + SIDE_POSITION[side]


func get_color_tile(value: int) -> ColorTile:
	"""
	Принимает нормализованный цвет (от 10 до 17)
	Возвращает Colortile
	"""
	var result: int = value

	for i in colors:
		var ct = ColorTile.create_from_color(i)
		if ct.color == value:
			return ct

	return


func remove_lock(color: int, lock_type: ColorTile.Type) -> void:
	var result: Array
	prints("remove_lock()", color, colors, lock_type)

	for i in colors.duplicate():
		var ct = ColorTile.create_from_color(i)
		prints("each color", i, ct.color, ct.color_value, ct.type, lock_type)
		if ct.type == lock_type:
			result.push_back(ct.color)
		else:
			result.push_back(i)

	prints("remove_lock() end", result, colors)
	colors = result
