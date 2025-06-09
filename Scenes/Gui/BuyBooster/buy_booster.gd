extends Control

const COINS_PRICE = 100
@export var booster: Booster: set = _set_booster


@onready var head_label: Label = $Background/HeadBackground/Label

@onready var for_coins: VBoxContainer = $Background/HBoxContainer/ForCoins
@onready var for_ads: VBoxContainer = $Background/HBoxContainer/ForAds


signal modal_close


func _ready() -> void:
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))


func _on_rewarded_state_changed(state):
	if state == "rewarded" and Bridge.advertisement.rewarded_placement == "buy_booster":
		prints("booster buyed!", for_ads.booster, for_ads.count)
		Player.add_booster(for_ads.booster.type, for_ads.count)
		modal_close.emit()


func _set_booster(value: Booster) -> void:
	booster = value

	_update_ui()


func _update_ui() -> void:
	if for_ads:
		for_ads.booster = booster

	if for_coins:
		for_coins.booster = booster

	if head_label:
		head_label.text = booster.get_not_booster_msg()


func _on_close_button_pressed() -> void:
	SFX.play_sound("click")
	modal_close.emit()


func _on_for_coins_buy_pressed(booster: Booster, count: Variant) -> void:
	prints("buyed for coins", booster, count)
	if Player.coins >= COINS_PRICE:
		EventBus.coins_changed.emit(Player.coins - COINS_PRICE)
		Player.add_booster(booster.type, count)
		modal_close.emit()


func _on_for_ads_buy_pressed(booster: Booster, count: Variant) -> void:
	prints("buyed for ads", booster, count)
	Bridge.advertisement.show_rewarded("buy_booster")
