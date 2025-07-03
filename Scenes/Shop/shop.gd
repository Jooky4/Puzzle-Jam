extends Control

var is_catalog_loaded: bool = false

var catalog_mock_data = [
	{
		"id": "coins_100",
		"title": "100 монет",
		"price": "1 РУБ",
		"priceValue": "1"
	},
	{
		"id": "coins_500",
		"title": "500 монет",
		"price": "19 РУБ",
		"priceValue": "19"
	},
	{
		"id": "coins_2000",
		"title": "2000 монет",
		"price": "69 РУБ",
		"priceValue": "69"
	},
	{
		"id": "coins_5000",
		"title": "5000 монет",
		"price": "139 РУБ",
		"priceValue": "139"
	},
	{
		"id": "coins_10000",
		"title": "10000 монет",
		"price": "239 РУБ",
		"priceValue": "239"
	},
	{
		"id": "boosters_mini",
		"title": "1 бустер",
		"price": "69 РУБ",
		"priceValue": "69"
	},
	{
		"id": "boosters_start",
		"title": "3 бустера",
		"price": "189 РУБ",
		"priceValue": "189"
	},
	{
		"id": "boosters_best",
		"title": "5 бустеров",
		"price": "299 РУБ",
		"priceValue": "299"
	},
	{
		"id": "boosters_big",
		"title": "10 бустеров",
		"price": "469 РУБ",
		"priceValue": "469"
	},
]


@onready var coin_pack: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack
@onready var coin_pack_2: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack2
@onready var coin_pack_3: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack3
@onready var coin_pack_4: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack4
@onready var coin_pack_5: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack5
@onready var coin_pack_6: Button = $ScrollContainer/VBoxContainer/Coins/MarginContainer/Panel/GridContainer/CoinPack6


@onready var coin_pack_list = [coin_pack_2, coin_pack_3, coin_pack_4, coin_pack_5, coin_pack_6]

@onready var booster_set: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet
@onready var booster_set_2: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet2
@onready var booster_set_3: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet3
@onready var booster_set_4: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet4

@onready var booster_set_list = [booster_set, booster_set_2, booster_set_3, booster_set_4]
@onready var coin_counter: Control = $Head/CoinCounter


var _cur_purchase: Node


func _ready() -> void:
	prints("shop ready")
	Gui.hide_default_ui()

	_update_ads_coins_button()

	coin_counter.value = Player.get_value("coins")
	if not is_catalog_loaded:
		_get_catalog()

	for i in coin_pack_list:
		i.pressed.connect(_on_coin_pack_pressed.bind(i))

	for i in [booster_set, booster_set_2, booster_set_3, booster_set_4]:
		i.pressed.connect(_on_booster_pressed.bind(i))

	EventBus.coins_changed.connect(_set_money)
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))


func _set_money(value: int) -> void:
	coin_counter.value = value


func _on_close_button_pressed() -> void:
	SFX.play_sound("click")
	ChangeScene.to("menu")


func _get_catalog() -> void:
	Bridge.payments.get_catalog(Callable(self, "_on_get_catalog_completed"))
	#_on_get_catalog_completed("OK", catalog_mock_data)


func _on_get_catalog_completed(success, catalog):
	is_catalog_loaded = true

	for item in catalog:
		if item.id.begins_with("coin"):
			for i in coin_pack_list:
				if i.purchase_id == item.id:
					var _price = _split_price(item.price)
					i.currency = _price[1]
					i.price = _price[0]
					break

		if item.id.begins_with("booster"):
			for i in booster_set_list:
				if i.purchase_id == item.id:
					var _price = _split_price(item.price)
					i.currency_char = _price[1]
					i.price = _price[0]
					break


func _split_price(value: String) -> Array:
	return value.split(" ")


func _on_coin_pack_pressed(coin_pack: Node) -> void:
	prints("coin_pack_pressed", coin_pack.purchase_id)
	SFX.play_sound("click")
	var id = coin_pack.purchase_id
	Bridge.payments.purchase(id, Callable(self, "_on_purchase_completed"))


func _on_booster_pressed(booster_set: Node) -> void:
	prints("booster_pressed", booster_set.type)
	SFX.play_sound("click")
	var id = booster_set.purchase_id
	Bridge.payments.purchase(id, Callable(self, "_on_purchase_completed"))


func _on_purchase_completed(success, purchase):
	prints("purchase", success, purchase)
	if success:
		prints("")
		match purchase.id:
			"coins_100":
				Player.set_value("coins", Player.get_value("coins") + 100)
			"coins_500":
				Player.set_value("coins", Player.get_value("coins") + 500)
			"coins_2000":
				Player.set_value("coins", Player.get_value("coins") + 2000)
			"coins_5000":
				Player.set_value("coins", Player.get_value("coins") + 5000)
			"coins_10000":
				Player.set_value("coins", Player.get_value("coins") + 10000)
			"boosters_mini":
				Player.set_value("hammer", Player.get_value("hammer") + 1)
				Player.set_value("bomb", Player.get_value("bomb") + 1)
				Player.set_value("shuffle", Player.get_value("shuffle") + 1)
			"boosters_start":
				Player.set_value("hammer", Player.get_value("hammer") + 3)
				Player.set_value("bomb", Player.get_value("bomb") + 3)
				Player.set_value("shuffle", Player.get_value("shuffle") + 3)
			"boosters_best":
				Player.set_value("hammer", Player.get_value("hammer") + 5)
				Player.set_value("bomb", Player.get_value("bomb") + 5)
				Player.set_value("shuffle", Player.get_value("shuffle") + 5)
			"boosters_big":
				Player.set_value("hammer", Player.get_value("hammer") + 10)
				Player.set_value("bomb", Player.get_value("bomb") + 10)
				Player.set_value("shuffle", Player.get_value("shuffle") + 10)

		Player.save_data()


func _on_ads_coin_pack_pressed() -> void:
	# проверяем что закончился кулдаун на получение монет за рекламу
	if Player.can_get_coins_by_ads():
		Bridge.advertisement.show_rewarded(Config.BUY_COINS_ADS)


func _on_rewarded_state_changed(state) -> void:
	prints("rewarded state", state)
	if state == "rewarded" and Bridge.advertisement.rewarded_placement == Config.BUY_COINS_ADS:
		EventBus.coins_changed.emit(100 + Player.coins)
		Player.update_last_coins_reward()
		Player.save_data()


func _on_disable_ads_button_timer_timeout() -> void:
	_update_ads_coins_button()

func _update_ads_coins_button() -> void:
	if Player.can_get_coins_by_ads():
		coin_pack._set_disabled(false)
	else:
		coin_pack._set_disabled(true)
