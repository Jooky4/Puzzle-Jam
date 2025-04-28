extends Control

@export var level: PackedScene


func _ready() -> void:
	Gui.show_main_menu_ui()


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_packed(level)
