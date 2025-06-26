class_name ColorTile extends Node

"""
	тип цветного тайла
	COMMON - Обычный цветной тайл
	все остальные - цветной тайл с примочкой (ключ, замок и т.д)
	https://docs.google.com/document/d/18OnKsO47aJFWwWle3FrUwR0puzr4-Bq-Yd3nOIvwpoI/edit?tab=t.0
"""
enum Type {
	COMMON,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4, # не используется
	KEY_5, # не используется
	LOCK_1,
	LOCK_2,
	LOCK_3,
	LOCK_4, # не используется
	LOCK_5, # не используется
	LIVE,
	ICE,
	ROCKET,
}

# начальное значение как записано в LevelData.levels. (напр. 10, 213, 1010 и т.д)
@export var color_value: int
# значение цвета от 10 до 17, он же normalized_color
@export var color: int
# цвет RGB
@export var rgb_color: Color
@export var type: Type

const LOCK_KEY_ALIAS = {
	Type.KEY_1: Type.LOCK_1,
	Type.KEY_2: Type.LOCK_2,
	Type.KEY_3: Type.LOCK_3,
}

func _to_string() -> String:
	var _result: String
	if is_lock():
		match type:
			Type.LOCK_1:
				_result = "bronze"
			Type.LOCK_2:
				_result = "silver"
			Type.LOCK_3:
				_result = "gold"

		_result = _result + " lock"

	if is_key():
		match type:
			Type.KEY_1:
				_result = "bronze"
			Type.KEY_2:
				_result = "silver"
			Type.KEY_3:
				_result = "gold"

		_result = _result + " key"

	if _result.length():
		_result = " " + _result

	return "<ColorTile %d(%d)%s>" % [color, color_value, _result]


static func get_lock_type(key_type: Type) -> Type:
	return LOCK_KEY_ALIAS[key_type]


static func create_from_color(value: int) -> ColorTile:
	var _color = value
	var _normalized_color = _color
	var block_type: ColorTile.Type = ColorTile.Type.COMMON

	# Это ключ?
	if _color >= 20 and _color <= 67:
		if _color <= 27:
			_normalized_color = _color - 10
			block_type = ColorTile.Type.KEY_1
		elif _color <= 37:
			_normalized_color = _color - 20
			block_type = ColorTile.Type.KEY_2
		elif _color <= 47:
			_normalized_color = _color - 30
			block_type = ColorTile.Type.KEY_3
		elif _color <= 57:
			_normalized_color = _color - 40
			block_type = ColorTile.Type.KEY_4
		else:
			_normalized_color = _color - 50
			block_type = ColorTile.Type.KEY_5

	# Это замок?
	elif _color >= 210 and _color <= 617:
			if _color <= 217:
				_normalized_color = _color - 200
				block_type = ColorTile.Type.LOCK_1
			elif _color <= 317:
				_normalized_color = _color - 300
				block_type = ColorTile.Type.LOCK_2
			elif _color <= 417:
				_normalized_color = _color - 400
				block_type = ColorTile.Type.LOCK_3
			elif _color <= 517:
				_normalized_color = _color - 500
				block_type = ColorTile.Type.LOCK_4
			else:
				_normalized_color = _color - 600
				block_type = ColorTile.Type.LOCK_5

	# Живой куб?
	elif _color >= 1010 and _color <= 1017:
		_normalized_color = _color - 1000
		block_type = ColorTile.Type.LIVE

	# Замороженный куб
	elif _color >= 2010 and _color <= 2017:
		_normalized_color = _color - 2000
		block_type = ColorTile.Type.ICE

	# Ракета
	elif _color >= 3010 and _color <= 3017:
		_normalized_color = _color - 3000
		block_type = ColorTile.Type.ROCKET

	var _rgb_color: Color
	if _normalized_color > 2:
		_rgb_color = LevelData.COLORS[_normalized_color]

	var _ct = ColorTile.new()
	_ct.color_value = value
	_ct.color = _normalized_color
	_ct.type = block_type
	_ct.rgb_color = _rgb_color

	return _ct


func is_key() -> bool:
	return type in [ColorTile.Type.KEY_1, ColorTile.Type.KEY_2, ColorTile.Type.KEY_3]


func is_lock() -> bool:
	return type in [ColorTile.Type.LOCK_1, ColorTile.Type.LOCK_2, ColorTile.Type.LOCK_3]


func is_same_color(value: int) -> bool:
	return color == value


func is_iced() -> bool:
	return type == Type.ICE
