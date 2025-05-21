extends Control


@onready var level_reward_label: Label = $LevelReward/Label
@onready var reward_twister: Control = $RewardTwister
@onready var animation_player: AnimationPlayer = $AnimationPlayer


signal next_level


func play_animation() -> void:
	animation_player.play("Start")


func update() -> void:
	reward_twister.start_animation()


func _on_next_button_pressed() -> void:
	next_level.emit()
