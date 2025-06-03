extends Control


func _ready() -> void:
	Player.load_data()
	EventBus.coins_changed.emit(Player.get_value("coins"))
	LevelManager.current_level = Player.get_value("current_level")

	if Player.is_play_first_time():
		ChangeScene.to("game")
	else:
		ChangeScene.to("main")

	Bridge.platform.send_message("game_ready")
