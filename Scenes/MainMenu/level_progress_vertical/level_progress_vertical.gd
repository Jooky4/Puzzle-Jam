extends Control

@onready var level_0: Control = $Level0
@onready var level_1: Control = $Level1
@onready var level_2: Control = $Level2
@onready var level_3: Control = $Level3
@onready var shadow: TextureRect = $Shadow

@onready var levels = [
	level_0,
	level_1,
	level_2,
	level_3,
]


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if Bridge.device.type == "mobile":
		shadow.hide()
	else:
		shadow.show()

	var _cur_level_idx = Player.get_value("current_level")

	for node in levels:
		node.level = _cur_level_idx + 1

		if _cur_level_idx in LevelData.hard_levels:
			node.type = "hard"
		elif _cur_level_idx in LevelData.super_hard_levels:
			node.type = "super_hard"
		else:
			node.type = "normal"

		node._update_ui()

		_cur_level_idx += 1
