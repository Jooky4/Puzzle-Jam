extends Control

signal next_level


func _on_next_button_pressed() -> void:
	next_level.emit()
