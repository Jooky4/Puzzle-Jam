extends Control

@export var level: PackedScene

@onready var play_button_label: Label = $PlayButton/PlayLabel
@onready var try_again_label: Label = $PlayButton/TryAgainLabel


func _ready() -> void:
	Gui.show_main_menu_ui()

	play_button_label.visible = not LevelManager.is_prev_gameover
	try_again_label.visible = LevelManager.is_prev_gameover


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_packed(level)


func _on_shop_button_pressed() -> void:
	prints("show shop")
