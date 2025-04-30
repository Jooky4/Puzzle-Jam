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

	prints("uniq", _arr, _dic)
	return _dic.keys()
