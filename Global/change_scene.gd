extends CanvasLayer

@export var game_scene: PackedScene

# TODO: заменить имена на enum?
var scene_aliases: Dictionary = {
	"game": "res://Scenes/Level/level.tscn",
	"menu": "res://Scenes/MainMenu/main_menu.tscn",
	"shop": "res://Scenes/Shop/shop.tscn",
}

@onready var color_rect = $ColorRect
@onready var animetionplayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var fps_indicator: Label = $FpsIndicator


func _ready():
	if Config.SHOW_FPS:
		fps_indicator.show()
	else:
		fps_indicator.hide()

	color_rect.visible = false


func black_screen() -> void:
	color_rect.visible = true
	animetionplayer.play("Black_screen")


func normal_screen() -> void:
	animetionplayer.play("Normal_screen")


func to(scene_name: String) -> void:
	prints("ChangeScene.to(%s)" % scene_name)
	if scene_aliases.has(scene_name):
		var _scene = scene_aliases[scene_name]
		var _status = get_tree().call_deferred("change_scene_to_file", _scene)

		if _status == OK:
			normal_screen()
		elif _status == ERR_CANT_OPEN:
			debug_label.text = "ERR_CANT_OPEN: %s" % _scene
		elif _status == ERR_CANT_CREATE:
			debug_label.text = "ERR_CANT_CREATE: %s" % _scene
