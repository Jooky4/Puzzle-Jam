@tool
extends Control

enum EColor {
	GREEN,
	YELLOW,
	RED,
	PURPLE,
}

@export var text: String: set = _set_text
@export var color: EColor: set = _set_color

@export var green: Texture
@export var yellow: Texture
@export var red: Texture
@export var purple: Texture

@onready var background: TextureRect = $Background
@onready var discount_value: Label = $VBoxContainer/DiscountValue

@onready var background_alias = {
	EColor.GREEN: green,
	EColor.YELLOW: yellow,
	EColor.RED: red,
	EColor.PURPLE: purple,
}

func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if background:
		background.texture = background_alias[color]

	if discount_value:
		discount_value.text = text


func _set_text(value: String) -> void:
	text = value

	_update_ui()


func _set_color(value: EColor) -> void:
	color = value

	_update_ui()
