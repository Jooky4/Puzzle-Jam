@tool
extends Control


@export var value: int: set = _set_value
@onready var value_label: Label = $Background/ValueLabel

signal plus_pressed

func _ready() -> void:
	_set_value(value)


func _set_value(_value: int) -> void:
	value = max(_value, 0)

	if value_label:
		_update_label()


func _update_label() -> void:
	value_label.text = Utils.format_number(value)


func _on_plus_button_pressed() -> void:
	SFX.play_sound("click")
	plus_pressed.emit()
