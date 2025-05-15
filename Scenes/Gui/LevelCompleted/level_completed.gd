extends Control


@onready var level_reward_label: Label = $LevelReward/Label

signal next_level


func _on_next_button_pressed() -> void:
	next_level.emit()
