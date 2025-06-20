@tool
extends VBoxContainer

@export var booster: Booster: set = _set_booster
@export_enum("coins", "ads") var buy_type: String


@onready var icon: TextureRect = $Control/Icon
@onready var count_label: Label = $Control/Icon/Count
@onready var buy_for_coins_btn: TextureButton = $BuyForCoins
@onready var buy_for_ads_btn: TextureButton = $BuyForADS
@onready var coins_label: Label = $BuyForCoins/Label


var count: int = 0
var _price_info: Dictionary

signal buy_pressed(booster: Booster, count, price)


func _ready() -> void:
	_update_ui()


func _set_booster(value: Booster) -> void:
	booster = value

	if not booster:
		return

	if buy_type == "coins":
		_price_info = booster.get_price()
	else:
		_price_info = booster.get_count_by_ads()

	count = _price_info.count

	_update_ui()


func _update_ui() -> void:
	if not booster:
		return

	if icon and booster:
		icon.texture = booster.icon

	if count_label:
		count_label.text = str(_price_info.count)

	if buy_for_ads_btn:
		buy_for_ads_btn.visible = buy_type == "ads"
		buy_for_coins_btn.visible = buy_type == "coins"

	if coins_label:
		if buy_type == "coins":
			coins_label.text = str(_price_info.cost)


func _on_buy_for_coins_pressed() -> void:
	buy_pressed.emit(booster, _price_info.count, _price_info.cost)


func _on_buy_for_ads_pressed() -> void:
	buy_pressed.emit(booster, _price_info.count, _price_info.cost)
