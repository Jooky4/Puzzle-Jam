extends Control


@export var texture_list: Array[Texture2D]

var color: int # смотри номера цветов в LevelData.COLORS
var count: int

@onready var label: Label = $Label
@onready var block: TextureRect = $Block
@onready var done: TextureRect = $Done


@onready var texture_binds = {
	10: texture_list[0],
	11: texture_list[1],
	12: texture_list[2],
	13: texture_list[3],
	14: texture_list[4],
	15: texture_list[5],
	16: texture_list[6],
	17: texture_list[7],
}


func _ready() -> void:
	prints("goal_color ready")
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

	if block:
		block.texture = texture_binds[value]
