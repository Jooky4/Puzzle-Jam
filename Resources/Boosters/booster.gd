class_name Booster extends Resource

enum EType {
	HAMMER,
	BOMB,
	SHUFFLE,
}

var enabled_in_level = {
	EType.HAMMER: 3,
	EType.BOMB: 7,
	EType.SHUFFLE: 5,
}

var description = {
	EType.HAMMER: tr("HAMMER_USE_DESC"),
	EType.BOMB: tr("BOMB_USE_DESC"),
	EType.SHUFFLE: "",
}

var no_booster_msg = {
	EType.HAMMER: tr("NO_HAMMERS"),
	EType.BOMB: tr("NO_BOMBS"),
	EType.SHUFFLE: tr("NO_SHUFFLES"),
}

var _coin_price = {
	EType.HAMMER: {
		"cost": 300,
		"count": 3,
	},
	EType.BOMB: {
		"cost": 1900,
		"count": 3,
	},
	EType.SHUFFLE: {
		"cost": 1200,
		"count": 3,
	},
}

var _ads_count = {
	EType.HAMMER: {
		"cost": 0,
		"count": 1,
	},
	EType.BOMB: {
		"cost": 0,
		"count": 1,
	},
	EType.SHUFFLE: {
		"cost": 0,
		"count": 1,
	},
}


@export var icon: Texture2D
@export var type: EType


func get_description() -> String:
	return description[type]


func get_not_booster_msg() -> String:
	return no_booster_msg[type]


func get_price() -> Dictionary:
	return _coin_price[type]


func get_count_by_ads() -> Dictionary:
	return _ads_count[type]


func is_enabled_on_level(level_index: int) -> bool:
	return level_index >= enabled_in_level[type]
