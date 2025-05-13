extends Node


func timeout(value: float) -> void:
	prints("timeout start", value)
	await get_tree().create_timer(value).timeout
	prints("timeout end")


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
