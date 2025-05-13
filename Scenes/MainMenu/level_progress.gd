@tool
extends Control

@export var value: int: set = _set_value
@export var level: int: set = _set_level

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var level_value: Label = $LevelValue


func _ready() -> void:
	_set_value(value)


func _set_value(_value: int) -> void:
	value = clamp(_value, 0, 100)

	if progress_bar:
		progress_bar.value = _value


func _set_level(_value: int) -> void:
	level = max(_value, 0)

	if level_value:
		level_value.text = str(_value)
