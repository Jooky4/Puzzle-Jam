extends Panel

@onready var sound_checkbox: Control = $Panel/VBoxContainer/Sound/SoundCheckbox
@onready var music_checkbox: Control = $Panel/VBoxContainer/Music/MusicCheckbox


signal modal_close


func _ready() -> void:
	EventBus.player_loaded.connect(_on_player_data_loaded)


func _on_player_data_loaded() -> void:
	var _sfx: int = Player.get_value("mute_sfx")
	var mute_sfx = bool(_sfx)
	sound_checkbox.set_value_no_signal(not mute_sfx)
	SFX.set_mute("SFX", mute_sfx)

	var _music: int = Player.get_value("mute_music")
	var mute_music = bool(_music)
	music_checkbox.set_value_no_signal(not mute_music)
	SFX.set_mute("Music", mute_sfx)


func _on_close_button_pressed() -> void:
	SFX.play_sound("click")
	modal_close.emit()


func _on_sound_checkbox_checked(value: Variant) -> void:
	SFX.set_mute("SFX", not value)
	var _sfx = int(not value)
	Player.set_value("mute_sfx", _sfx)
	Player.save_data()


func _on_music_checkbox_checked(value: Variant) -> void:
	SFX.set_mute("Music", not value)
	var _music = int(not value)
	Player.set_value("mute_music", _music)
	Player.save_data()
