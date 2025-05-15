extends Control


@onready var level_reward_label: Label = $LevelReward/Label
@onready var reward_twister: Control = $RewardTwister

signal next_level


func update() -> void:
	reward_twister.start_animation()


func _on_next_button_pressed() -> void:
	next_level.emit()
