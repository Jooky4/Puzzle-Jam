@tool
extends Control

@export var value: bool = false
@export var active_bg: Texture2D
@export var inactive_bg: Texture2D

@onready var background: TextureRect = $Button/Background
@onready var handler: TextureRect = $Button/Handler
@onready var button: Button = $Button

signal checked(val)

const LEFT_POS = 0
const RIGHT_POS = 54


func _ready() -> void:
	button.button_pressed = value


func set_value_no_signal(_value: bool) -> void:
	value = _value

	if button:
		button.set_pressed_no_signal(value)
		_update_checkbox(value)


func set_value(_value: bool) -> void:
	value = _value

	if button:
		button.button_pressed = value


func _update_checkbox(value: bool) -> void:
	if value:
		background.texture = active_bg
		_move_handler(RIGHT_POS)
	else:
		background.texture = inactive_bg
		_move_handler(LEFT_POS)


func _on_checkbox_toggled(toggled_on: bool) -> void:
	value = toggled_on

	_update_checkbox(toggled_on)

	checked.emit(toggled_on)


func _move_handler(pos: int) -> void:
	var t = create_tween()
	t.tween_property(handler, "position:x", pos, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
	t.play()
