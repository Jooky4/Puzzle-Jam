extends Control

@export var level: PackedScene

@onready var play_button_label: Label = $PlayButton/PlayLabel
@onready var try_again_label: Label = $PlayButton/TryAgainLabel
@onready var level_progress: Control = $LevelProgress2

@onready var desktop_bg: Node2D = $DesktopBG
@onready var mobile_bg: TextureRect = $CanvasLayer/MobileBG
@onready var shadow: TextureRect = $CanvasLayer2/Shadow


func _ready() -> void:
	if Bridge.device.type == "mobile":
		desktop_bg.hide()
		mobile_bg.show()
		shadow.show()
	else:
		desktop_bg.show()
		mobile_bg.hide()
		shadow.hide()

	Gui.show_main_menu_ui()

	play_button_label.show()
	#level_progress.level = Player.get_value("current_level") + 1
	#play_button_label.visible = not LevelManager.is_prev_gameover
	#try_again_label.visible = LevelManager.is_prev_gameover
	EventBus.player_loaded.connect(_on_update_level)
	_on_update_level()


func _on_update_level() -> void:
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
