extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play() -> void:
	animation_player.play("bomb_fall")
	await Utils.timeout(0.4)
	SFX.play_sound("bomb")
