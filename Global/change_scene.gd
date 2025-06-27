extends CanvasLayer

const DEBUG = false

@export var game_scene: String

# TODO: заменить имена на enum?
var scene_aliases: Dictionary = {
	"game": "res://Scenes/Level/level.tscn",
	"menu": "res://Scenes/MainMenu/main_menu.tscn",
	"shop": "res://Scenes/Shop/shop.tscn",
	"leaderboard": "res://Scenes/Leaderboard/leaderboard.tscn"
}

@onready var color_rect = $ColorRect
@onready var animetionplayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var fps_indicator: Label = $FpsIndicator
@onready var version_label: Label = $VersionLabel


func _ready():
	fps_indicator.visible = Config.SHOW_FPS

	color_rect.visible = false
	if Config.CHEATS_ENABLED:
		debug_label.text = "cheats enabled"


func black_screen() -> void:
	color_rect.visible = true
	animetionplayer.play("Black_screen")


func normal_screen() -> void:
	animetionplayer.play("Normal_screen")


func to(scene_name: String) -> void:
	if DEBUG:
		prints("ChangeScene.to(%s)" % scene_name)

	EventBus.change_scene.emit(scene_name)

	if scene_aliases.has(scene_name):
		game_scene = scene_name
		var _scene = scene_aliases[scene_name]
		var _status = get_tree().call_deferred("change_scene_to_file", _scene)

		if _status == OK:
			normal_screen()
		elif _status == ERR_CANT_OPEN:
			debug_label.text = "ERR_CANT_OPEN: %s" % _scene
		elif _status == ERR_CANT_CREATE:
			debug_label.text = "ERR_CANT_CREATE: %s" % _scene
