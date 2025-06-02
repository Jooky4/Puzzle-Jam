extends Control


signal close


func _ready() -> void:
	prints("shop ready")
	Gui.show_default_ui()


func _on_close_button_pressed() -> void:
	close.emit()
