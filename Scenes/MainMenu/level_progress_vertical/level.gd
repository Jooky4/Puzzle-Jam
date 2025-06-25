extends Control

@export_enum("normal", "hard", "super_hard") var type: String
@export var is_shadowed: bool
@export var is_active: bool
@export var level: int

@export var normal_bg: Texture2D
@export var hard_bg: Texture2D
@export var super_hard_bg: Texture2D
@export var reached_line: Texture2D
@export var disabled_line: Texture2D


@onready var background: TextureRect = $Background
@onready var level_label: Label = $Background/LevelLabel
@onready var lock: TextureRect = $Background/Lock
@onready var skull_bg: TextureRect = $Background/Skull_bg
@onready var line: NinePatchRect = $Line


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if not background:
		return

	level_label.text = str(level)
	skull_bg.hide()

	lock.visible = not is_active
	if not is_active:
		line.texture = disabled_line
	else:
		line.texture = reached_line

	match type:
		"normal":
			background.texture = normal_bg
			background.self_modulate = Color(0, 1, 0)
		"hard":
			background.texture = hard_bg
			background.self_modulate = Color(1,1,1)
		"super_hard":
			background.texture = super_hard_bg
			background.self_modulate = Color(1,1,1)
			skull_bg.show()

	if is_shadowed:
		background.texture = normal_bg
		background.self_modulate = Color(1,1,1)
