extends Node


var data = {
	"gold": 0,
	"current_level": 0
}


func is_play_first_time() -> bool:
	return data.current_level == 0


func save_data():
	var config = ConfigFile.new()

	config.set_value("player", "money", data.gold)
	config.set_value("player", "current_level", data.current_level)
	var err = config.save("user://player.cfg")


func load_data():
	var config = ConfigFile.new()
	var error = config.load("user://player.cfg")
	if error == OK:
		data.gold = config.get_value("player", "gold", 0)
		data.current_level = config.get_value("player", "current_level", 0)
