extends Node

var _data = {
	"coins": 0,
	"current_level": 0, # индекс уровня
	"hammer": 0,
	"bomb": 0,
	"shuffle": 0,
	"mute_sfx": false,
	"mute_music": false,
}

var booster_name = {
	Booster.EType.HAMMER: "hammer",
	Booster.EType.BOMB: "bomb",
	Booster.EType.SHUFFLE: "shuffle",
}


func _ready() -> void:
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.booster_used.connect(_on_booster_used)


func get_booster_count(booster_type: Booster.EType) -> int:
	return get_value(booster_name[booster_type])


func add_booster(booster_type: Booster.EType, count: int) -> void:
	var cur_data_name = booster_name[booster_type]
	var old_value = get_booster_count(booster_type)
	set_value(cur_data_name, max(old_value + count, 0))


func _on_booster_used(booster_type: Booster.EType) -> void:
	var cur_data_name = booster_name[booster_type]
	var old_value = get_booster_count(booster_type)
	set_value(cur_data_name, max(old_value - 1, 0))


func _on_coins_changed(value: int) -> void:
	set_value("coins", value)
	prints("player on coins changed", get_value("coins"))


func is_play_first_time() -> bool:
	return _data.current_level == 0


func _get(property):
	if property in _data.keys():
		return _data[property]


func set_value(key: String, value) -> void:
	if key in _data.keys():
		_data[key] = value
		EventBus.player_data_changed.emit(key)


func get_value(key: String):
	if key in _data.keys():
		return _data[key]

	return null


func save_data():
	prints("Player.save_data()", _data)
	var config = ConfigFile.new()

	config.set_value("player", "coins", get_value("coins"))
	config.set_value("player", "current_level", get_value("current_level"))

	config.set_value("player", "hammer", get_value("hammer"))
	config.set_value("player", "bomb", get_value("bomb"))
	config.set_value("player", "shuffle", get_value("shuffle"))
	config.set_value("player", "mute_sfx", get_value("mute_sfx"))
	config.set_value("player", "mute_music", get_value("mute_music"))

	var err = config.save("user://player.cfg")


func load_data():
	var config = ConfigFile.new()
	var error = config.load("user://player.cfg")
	if error == OK:
		prints("load data OK")
		set_value("coins", config.get_value("player", "coins", 0))
		set_value("current_level", config.get_value("player", "current_level", 0))
		set_value("hammer", config.get_value("player", "hammer"))
		set_value("bomb", config.get_value("player", "bomb"))
		set_value("shuffle", config.get_value("player", "shuffle"))
		set_value("mute_sfx", config.get_value("player", "mute_sfx"))
		set_value("mute_music", config.get_value("player", "mute_music"))

	EventBus.player_loaded.emit()
