extends Control

const LEVEL_REWARD_ADS = "level_reward_ads"

@export var reward: int: set = _set_reward
var _bonus_reward: int

@onready var level_reward_label: Label = $LevelReward/Label
@onready var reward_twister: Control = $RewardTwister
@onready var animation_player: AnimationPlayer = $AnimationPlayer


signal next_level


func _ready() -> void:
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))


func _on_rewarded_state_changed(status: String) -> void:
	""" покупка попытки пройти уровень за рекламу """

	if Bridge.advertisement.rewarded_placement == LEVEL_REWARD_ADS:
		if status == "rewarded":
			reward = _bonus_reward
			EventBus.coins_changed.emit(Player.coins + reward)
			Player.save_data()
			if LevelManager.current_level > Config.LEVEL_COMPLETE_MAIN_MENU:
				reward_twister.hide()
			else:
				next_level.emit()

		elif status == "closed":
			if LevelManager.current_level <= Config.LEVEL_COMPLETE_MAIN_MENU:
				next_level.emit()



func _set_reward(value: int) -> void:
	reward = value

	_update_ui()


func _update_ui() -> void:
	if level_reward_label:
		level_reward_label.text = str(reward)

	if reward_twister:
		reward_twister.base_value = reward


func play_animation() -> void:
	prints("level complete play animation")
	animation_player.play("Start")
	SFX.play_sound("victory")


func update() -> void:
	reward_twister.show()
	reward_twister.start_animation()


func _on_next_button_pressed() -> void:
	EventBus.coins_changed.emit(Player.coins + reward)
	if LevelManager.current_level > Config.LEVEL_COMPLETE_MAIN_MENU:
		ChangeScene.to("menu")

	next_level.emit()


func _on_reward_twister_reward(value: int) -> void:
	_bonus_reward = value
	Bridge.advertisement.show_rewarded(LEVEL_REWARD_ADS)
