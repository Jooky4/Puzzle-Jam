extends Control

@export var level: PackedScene

@onready var play_button_label: Label = $PlayButton/PlayLabel
@onready var try_again_label: Label = $PlayButton/TryAgainLabel
@onready var level_progress: Control = $LevelProgress2


func _ready() -> void:
	Gui.show_main_menu_ui()

	#level_progress.level = Player.get_value("current_level") + 1
	play_button_label.visible = not LevelManager.is_prev_gameover
	#try_again_label.visible = LevelManager.is_prev_gameover
	EventBus.player_loaded.connect(_on_update_level)
	_on_update_level()


func _on_update_level() -> void:
	prints("main menu on update", Player._data, Player.get_value("current_level"))
	var _level_idx = Player.get_value("current_level")
	#level_progress.level =  + 1
	play_button_label.text = tr("LEVEL") + " " + str(_level_idx + 1)
	#play_button_label.visible = not LevelManager.is_prev_gameover
	#try_again_label.visible = LevelManager.is_prev_gameover


func _on_play_button_pressed() -> void:
	SFX.play_sound("click")
	ChangeScene.to("game")


func _on_shop_button_pressed() -> void:
	SFX.play_sound("click")
	ChangeScene.to("shop")


func _on_button_pressed() -> void:
	ChangeScene.to("leaderboard")
