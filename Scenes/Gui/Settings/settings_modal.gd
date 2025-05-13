extends Panel


signal modal_close

func _on_close_button_pressed() -> void:
	modal_close.emit()


func _on_sound_checkbox_checked(val: Variant) -> void:
	prints("sound", val)


func _on_music_checkbox_checked(val: Variant) -> void:
	prints("music", val)
