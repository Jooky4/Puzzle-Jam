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

@export var icon: Texture2D
@export var type: EType


func get_description() -> String:
	return description[type]
