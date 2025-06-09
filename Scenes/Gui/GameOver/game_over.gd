extends Control


@export var goals: Dictionary: set = _set_goals


@onready var goal_color_controller: Control = $GoalColorController

const TRY_AGAIN_ADS = "try_again"

signal restart_level
# сигнал при нажатии на крестик - переход в главное меню
signal go_home
# сигнал при покупке ещё одной попытки - скрытие модалки и продолжение игры
signal close


func _ready() -> void:
	EventBus.goals_changed.connect(_set_goals)
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))


func _on_rewarded_state_changed(status: String) -> void:
	""" покупка попытки пройти уровень за рекламу """
	if status == "rewarded" and Bridge.advertisement.rewarded_placement == TRY_AGAIN_ADS:
		prints("try again for ads")
		EventBus.buy_free_cell_on_level.emit(5)
		close.emit()


func _set_goals(value: Dictionary) -> void:
	goal_color_controller.set_colors(value)


func _on_restart_button_pressed() -> void:
	restart_level.emit()


func _on_close_button_pressed() -> void:
	go_home.emit()


func _on_try_again_for_coin_pressed() -> void:
	prints("player has", Player.coins, "coins")

	if Player.coins >= 900:
		EventBus.coins_changed.emit(Player.coins - 900)
		EventBus.buy_free_cell_on_level.emit(5)
		close.emit()
		prints("player has 900 coins")


func _on_try_again_for_ads_pressed() -> void:
	Bridge.advertisement.show_rewarded(TRY_AGAIN_ADS)
