extends Panel


signal modal_close
signal mute_toggled(value: bool)

func _on_close_button_pressed() -> void:
	SFX.play_sound("click")
	modal_close.emit()


func _on_sound_checkbox_checked(value: Variant) -> void:
	SFX.set_mute(not value)


func _on_music_checkbox_checked(val: Variant) -> void:
	prints("music", val)
