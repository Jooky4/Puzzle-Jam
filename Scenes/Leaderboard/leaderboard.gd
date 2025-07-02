extends Control

@export var record: PackedScene
@export var space: PackedScene

@onready var v_box_container: VBoxContainer = %VBoxContainer

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
	prints("leaderboard ready")
	Gui.hide_default_ui()

	var options = {
		"leaderboardName": Config.LEADERBOARD_NAME,
		"quantityTop": 10,
		"includeUser": true,
		"quantityAround": 1
	}
	Bridge.leaderboard.get_entries(options, Callable(self, "_on_get_entries_completed"))


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
