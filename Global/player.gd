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
