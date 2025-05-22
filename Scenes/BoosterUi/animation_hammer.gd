extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play() -> void:
	animation_player.play("hammer_kick")
