extends Node


var _data = {
	"money": 0,
	"current_level": 0 # индекс уровня
}

signal data_updated(key: String)


func is_play_first_time() -> bool:
	return _data.current_level == 0


func _get(property):
	if property in _data.keys():
		return _data[property]


func set_value(key: String, value) -> void:
	if key in _data.keys():
		_data[key] = value
		data_updated.emit(key)


func get_value(key: String):
	if key in _data.keys():
		return _data[key]

	return null


func save_data():
	var config = ConfigFile.new()

	config.set_value("player", "money", get_value("money"))
	config.set_value("player", "current_level", get_value("current_level"))
	var err = config.save("user://player.cfg")


func load_data():
	var config = ConfigFile.new()
	var error = config.load("user://player.cfg")
	if error == OK:
		set_value("money", config.get_value("player", "money", 0))
		set_value("current_level", config.get_value("player", "current_level", 0))
