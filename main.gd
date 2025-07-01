extends Control


func _ready() -> void:
	EventBus.player_loaded.connect(_on_player_data_loaded)
	Player.load_data()
	EventBus.coins_changed.emit(Player.coins)
	LevelManager.current_level = Player.get_value("current_level")

	var lang = Bridge.platform.language
	TranslationServer.set_locale(lang)

	Bridge.platform.send_message("game_ready")


func _on_player_data_loaded() -> void:
	prints("MAIN: player data loaded")

	if Player.is_play_first_time():
		ChangeScene.to("game")
	else:
		ChangeScene.to("menu")
