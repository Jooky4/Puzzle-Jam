@tool
extends Control


@export var value: int: set = _set_value
@onready var value_label: Label = $ValueLabel


func _ready() -> void:
	_set_value(value)


func _set_value(_value: int) -> void:
	value = max(_value, 0)

	if value_label:
		_update_label()


func _update_label() -> void:
	value_label.text = Utils.format_number(value)
