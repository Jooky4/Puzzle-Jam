class_name Booster extends Resource

enum EType {
	HAMMER,
	BOMB,
	SHUFFLE,
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
		"cost": 700,
		"count": 2,
	},
	EType.SHUFFLE: {
		"cost": 900,
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
