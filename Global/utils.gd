extends Node


func timeout(value: float) -> void:
	await get_tree().create_timer(value).timeout


func uniq_array(arr: Array) -> Array:
	var _arr = arr.duplicate(true)
	var _dic: Dictionary

	for i in _arr:
		_dic[i] = true

	return _dic.keys()


func format_number(n: int) -> String:
	var result: String

	if n >= 1_000_000:
		result = str(float(n) / 1_000_000).replace(",", ".") + "KK"
	elif n >= 1_000:
		result = ("%.1f" % (float(n) / 1_000)).replace(".0", "") + "K"
	else:
		result = str(n)

	return result


func get_index_by_pos(pos: Vector2i, row_size: int) -> int:
	return pos.y * row_size + pos.x


func find_center_of_position_list(list: Array) -> Vector2:
	if list.is_empty():
		return Vector2.ZERO

	var sum = Vector2.ZERO
	for _pos in list:
		sum += _pos

	return sum / list.size()
