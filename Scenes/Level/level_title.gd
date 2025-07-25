extends Control

@export var level_value: int: set = _set_level_value
@export_enum("normal", "hard", "super_hard") var difficulty: set = _set_diff

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
		label.text = tr("TITLE_LEVEL") + " " + str(level_value) # + "(%s)" % LevelManager.get_real_level_number()

	if difficulty:
		hard_label.visible = difficulty == "hard"
		very_hard_label.visible = difficulty == "super_hard"
