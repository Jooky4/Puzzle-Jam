extends Control


# Тип ключа
@export var type: ColorTile.Type: set = _set_type

@export var gold_key_texture: Texture2D
@export var silver_key_texture: Texture2D
@export var bronze_key_texture: Texture2D


@onready var key_sprite: TextureRect = $KeySprite


func _set_type(value: ColorTile.Type) -> void:
	type = value

	if not key_sprite:
		return

	match type:
		ColorTile.Type.KEY_1:
			key_sprite.texture = bronze_key_texture
		ColorTile.Type.KEY_2:
			key_sprite.texture = silver_key_texture
		ColorTile.Type.KEY_3:
			key_sprite.texture = gold_key_texture
