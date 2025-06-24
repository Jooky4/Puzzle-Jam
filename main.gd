extends Control


func _ready() -> void:
	Player.load_data()
	EventBus.coins_changed.emit(Player.coins)
	LevelManager.current_level = Player.get_value("current_level")

	var lang = Bridge.platform.language
	prints("platform lang", lang)
	TranslationServer.set_locale(lang)

	if Player.is_play_first_time():
		ChangeScene.to("game")
	else:
		ChangeScene.to("menu")

	Bridge.platform.send_message("game_ready")
