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


@onready var booster_set: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet
@onready var booster_set_2: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet2
@onready var booster_set_3: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet3
@onready var booster_set_4: Button = $ScrollContainer/VBoxContainer/BoosterPack/MarginContainer/Panel/VBoxContainer/BoosterSet4



func _ready() -> void:
	prints("shop ready")
	Gui.show_default_ui()

	if not is_catalog_loaded:
		_get_catalog()

	for i in [coin_pack, coin_pack_2, coin_pack_3, coin_pack_4, coin_pack_5, coin_pack_6]:
		i.pressed.connect(_on_coin_pack_pressed.bind(i))

	for i in [booster_set, booster_set_2, booster_set_3, booster_set_4]:
		i.pressed.connect(_on_booster_pressed.bind(i))


func _on_close_button_pressed() -> void:
	ChangeScene.to("menu")


func _get_catalog() -> void:
	Bridge.payments.get_catalog(Callable(self, "_on_get_catalog_completed"))
	#_on_get_catalog_completed("OK", catalog_mock_data)


func _on_get_catalog_completed(success, catalog):
	is_catalog_loaded = true
	print(success, catalog)

	for item in catalog:
		print("ID: " + str(item.id))
		print("Price: " + str(item.price))
		#print("Price Currency Code: " + str(item.priceCurrencyCode))
		print("Price Value: " + str(item.priceValue))


func _on_coin_pack_pressed(coin_pack: Node) -> void:
	prints("coin_pack_pressed", coin_pack.purchase_id)

	var id = coin_pack.purchase_id
	Bridge.payments.purchase(id, Callable(self, "_on_purchase_completed"))


func _on_booster_pressed(booster_set: Node) -> void:
	prints("booster_pressed", booster_set.type)

	var id = booster_set.purchase_id
	Bridge.payments.purchase(id, Callable(self, "_on_purchase_completed"))


func _on_purchase_completed(success, purchase):
	print(success)
	print(purchase)
