extends Control

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	Player.load_data()
	EventBus.coins_changed.emit(Player.get_value("coins"))
	LevelManager.current_level = Player.get_value("current_level")

	if Player.is_play_first_time():
		get_tree().change_scene_to_packed(game_scene)
	else:
		get_tree().change_scene_to_packed(main_menu_scene)

	Bridge.platform.send_message("game_ready")
