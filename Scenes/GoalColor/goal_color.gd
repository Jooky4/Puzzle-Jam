extends Control


@export var texture_list: Array[Texture2D]

var color: int # смотри номера цветов в LevelData.COLORS
var count: int

@onready var label: Label = $Label
@onready var done: TextureRect = $Done
@onready var color_tile: ColorTile2D = $ColorTile


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if label:
		label.text = str(count)
		label.visible = count > 0

	if done:
		done.visible = count == 0


func set_count(value: int) -> void:
	var new_count = max(0, value)

	if count > 0 and new_count == 0:
		#prints("goal reached!", color)
		SFX.play_sound("target_2")

	count = new_count

	_update_ui()


func set_color(value: int) -> void:
	color = value
	color_tile.color = color
