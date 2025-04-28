extends Control

signal restart_level


func _on_restart_button_pressed() -> void:
	restart_level.emit()
