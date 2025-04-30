extends Control


var color: int # смотри номера цветов в LevelData.COLORS
var count: int

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label


func set_count(value: int) -> void:
	count = max(0, value)

	if label:
		label.text = str(value)


func set_color(value: int) -> void:
	color = value

	if color_rect:
		color_rect.color = LevelData.COLORS[value]
