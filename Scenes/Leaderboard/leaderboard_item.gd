extends Control


@export var best_bg: Texture2D
@export var common_bg: Texture2D
@export var current_bg: Texture2D

@export var gold_medal: Texture2D
@export var silver_medal: Texture2D
@export var bronze_medal: Texture2D

@export var player_name: String: set = _set_player_name
@export var score: int: set = _set_score
@export var rank: int: set = _set_rank

@export var is_current: bool = false: set = _set_current

@onready var score_label: Label = %ScoreLabel
@onready var player_name_label: Label = %PlayerNameLabel
@onready var rank_label: Label = %RankLabel
@onready var winner_background: TextureRect = $WinnerBackground
@onready var medal_background: TextureRect = %Medal


func _set_player_name(value: String) -> void:
	player_name = value

	_update_ui()


func _set_score(value: int) -> void:
	score = value

	_update_ui()


func _set_current(value: bool) -> void:
	is_current = value

	_update_ui()


func _set_rank(value: int) -> void:
	rank = value

	_update_ui()


func _update_ui() -> void:
	if player_name_label:
		player_name_label.text = player_name

	if score_label:
		score_label.text = str(score)

	if rank_label:
		rank_label.text = str(rank)
		if rank == 1:
			winner_background.texture = best_bg
			medal_background.texture = gold_medal
		else:
			winner_background.texture = common_bg

			if rank == 2:
				medal_background.texture = silver_medal
			elif rank == 3:
				medal_background.texture = bronze_medal
			else:
				rank_label.label_settings.font_color = Color("3a048e")

	if is_current and winner_background:
		winner_background.texture = current_bg
