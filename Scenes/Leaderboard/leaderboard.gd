extends Control

@export var record: PackedScene

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
		"quantityAround": 3
	}
	Bridge.leaderboard.get_entries(options, Callable(self, "_on_get_entries_completed"))


func _on_get_entries_completed(success, entries) -> void:
	prints("leaderboard list", entries)

	for i in entries:
		prints("entry", i, i.name)
		var record_node := record.instantiate()
		v_box_container.add_child(record_node)
		record_node.rank = i.rank
		record_node.player_name = i.name
		record_node.score = i.score
