extends Control


@export var goals: Dictionary: set = _set_goals
@onready var goal_color_controller: Control = $GoalColorController

signal restart_level
signal go_home


func _ready() -> void:
	EventBus.goals_changed.connect(_set_goals)


func _set_goals(value: Dictionary) -> void:
	goal_color_controller.set_colors(value)


func _on_restart_button_pressed() -> void:
	restart_level.emit()


func _on_close_button_pressed() -> void:
	go_home.emit()
