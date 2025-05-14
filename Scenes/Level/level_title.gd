extends Control

@export var level_value: int: set = _set_level_value
@export_enum("normal", "hard", "very_hard") var difficulty: set = _set_diff

@onready var label: Label = $Label

@onready var hard_label: TextureRect = $Hard
@onready var very_hard_label: TextureRect = $VeryHard


func _ready() -> void:
	_update_ui()


func _set_level_value(value: int) -> void:
	level_value = value

	_update_ui()


func _set_diff(value: String) -> void:
	difficulty = value

	_update_ui()


func _update_ui() -> void:
	if label:
		label.text = "уровень" + " " + str(level_value)

	hard_label.visible = difficulty == "hard"
	very_hard_label.visible = difficulty == "very_hard"
