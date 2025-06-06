@tool
extends VBoxContainer

@export var count: int
@export var booster: Booster: set = _set_booster
@export_enum("coins", "ads") var buy_type: String


@onready var icon: TextureRect = $Control/Icon
@onready var count_label: Label = $Control/Icon/Count
@onready var buy_for_coins_btn: TextureButton = $BuyForCoins
@onready var buy_for_ads_btn: TextureButton = $BuyForADS


signal buy_pressed(booster: Booster, count)


func _ready() -> void:
	_update_ui()


func _set_booster(value: Booster) -> void:
	booster = value

	_update_ui()


func _update_ui() -> void:
	if icon and booster:
		icon.texture = booster.icon

	if count_label:
		count_label.text = str(count)

	if buy_for_ads_btn:
		buy_for_ads_btn.visible = buy_type == "ads"
		buy_for_coins_btn.visible = buy_type == "coins"


func _on_buy_for_coins_pressed() -> void:
	buy_pressed.emit(booster, count)


func _on_buy_for_ads_pressed() -> void:
	buy_pressed.emit(booster, count)
