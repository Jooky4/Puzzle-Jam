extends Node

"""
Шина сообщений.

Как пользоваться:
	1) подклчить этот скрипт как глобальный синглтон (через настройки проекта)
	2) добавить сигнал в этот скрипт: signal coins_changed
	3) посылать сигнал из любого скрипта: EventBus.coins_changed.emit()
	4) подписаться на сигнал из любого другого скрипта: EventBus.coins_changed.connect(_on_coins_changed)
"""

signal goals_changed(goals: Dictionary)
signal coins_changed(count: int)
signal game_over
signal level_complete(level_number: int)
signal booster_used(booster_type: Booster.EType)
signal player_data_changed(name: String)
signal player_loaded
signal buy_booster(booster_type: Booster)
signal change_scene(scene_name: String)

# На экране GameOver освобождает N-ячеек за монеты/рекламу, что-бы продолжить игру
signal buy_free_cell_on_level(cell_count: int)
