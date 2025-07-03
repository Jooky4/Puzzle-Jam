extends Control

@export var record: PackedScene
@export var space: PackedScene

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var auth_control: Control = $AuthControl

@onready var mobile_bg: CanvasLayer = $CanvasLayer
@onready var desktop_bg: Control = $Background2
@onready var desktop_bg2: TextureRect = $Background


var lb_data = [
	{
		"rank": 0,
		"name": "Марина",
		"score": 101
	},
	{
		"rank": 1,
		"name": "Маргарита",
		"score": 99
	},
	{
		"rank": 2,
		"name": "Анатолий",
		"score": 98
	},
	{
		"rank": 3,
		"name": "YUBODOC",
		"score": 80
	},
	{
		"rank": 4,
		"name": "YUBODOC",
		"score": 80
	},
	{
		"rank": 5,
		"name": "YUBODOC",
		"score": 80
	},
	{
		"rank": 6,
		"name": "YUBODOC",
		"score": 80
	},
]


func _ready() -> void:
	Gui.hide_default_ui()

	if Bridge.device.type == "mobile":
		desktop_bg.hide()
		desktop_bg2.hide()
		mobile_bg.show()
	else:
		desktop_bg.show()
		desktop_bg2.show()
		mobile_bg.hide()

	if Bridge.player.is_authorized:
		_update_lb()
		v_box_container.show()
		auth_control.hide()
	else:
		v_box_container.hide()
		auth_control.show()

func _update_lb() -> void:
	var options = {
		"leaderboardName": Config.LEADERBOARD_NAME,
		"quantityTop": 10,
		"includeUser": true,
		"quantityAround": 1
	}
	Bridge.leaderboard.get_entries(options, Callable(self, "_on_get_entries_completed"))


func _on_player_authorize_completed(success):
	if success:
		print("Authorized")
		var _options = {
			"leaderboardName": Config.LEADERBOARD_NAME,
			"score": Player.get_value("current_level")
		}
		Bridge.leaderboard.set_score(_options)
		_update_lb()
		v_box_container.show()
		auth_control.hide()
	else:
		print("Authorization error")


func _on_get_entries_completed(success, entries) -> void:
	prints("_on_get_entries_completed", success, entries)
	var cur_user_id = Bridge.player.id

	var _prev_rank := 0

	for i in entries:
		var record_node := record.instantiate()
		v_box_container.add_child(record_node)
		record_node.rank = i.rank
		record_node.player_name = i.name
		record_node.score = i.score
		if i.id == cur_user_id:
			record_node.is_current = true

		if _prev_rank + 1 < i.rank and entries[-1] != i:
			var space_node = space.instantiate()
			v_box_container.add_child(space_node)

		_prev_rank = i.rank


func _on_auth_button_pressed() -> void:
	var options = {
		"scopes": true
	}
	Bridge.player.authorize(options, Callable(self, "_on_player_authorize_completed"))
