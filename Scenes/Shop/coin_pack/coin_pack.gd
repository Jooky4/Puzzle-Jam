@tool
extends Button

@export var price: int
@export var currency: String = "руб"
@export var count: int
@export var info: Info

enum Info {
	NONE,
	WARNING,
	DISCOUNT_10,
	DISCOUNT_30,
	DISCOUNT_40,
	DISCOUNT_50,
}

var coin_image_paths = {
	100: "res://Assets/shop/coin_pack/coin_100.png",
	500: "res://Assets/shop/coin_pack/coin_500.png",
	2000: "res://Assets/shop/coin_pack/coin_2k.png",
	5000: "res://Assets/shop/coin_pack/coin_5k.png",
	10000: "res://Assets/shop/coin_pack/coin_10k.png",
}

@onready var coin_image: TextureRect = $CoinImage

@onready var ads_label: HBoxContainer = %AdsLabel
@onready var price_label: Label = %PriceLabel
@onready var warning: TextureRect = $Indicator/Warning
@onready var discount_flag: Control = $Indicator/DiscountFlag
@onready var count_label: Label = $Count

var discount_bind = {
	Info.DISCOUNT_10: 0,
	Info.DISCOUNT_30: 1,
	Info.DISCOUNT_40: 2,
	Info.DISCOUNT_50: 3,
}

var discount_text_bind = {
	Info.DISCOUNT_10: "10%",
	Info.DISCOUNT_30: "30%",
	Info.DISCOUNT_40: "40%",
	Info.DISCOUNT_50: "50%",
}

func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	_update_coin_image(count)

	if count_label:
		count_label.text = str(count)

	if ads_label:
		ads_label.visible = price == 0

	if price_label:
		price_label.visible = price > 0
		price_label.text = str(price) + " " + currency

	match info:
		Info.WARNING:
			warning.show()
		Info.DISCOUNT_10,Info.DISCOUNT_30,Info.DISCOUNT_40:
			discount_flag.show()
			discount_flag.color = discount_bind[info]
			discount_flag.text = discount_text_bind[info]


func _update_coin_image(value: int) -> void:
	var texture
	if value in coin_image_paths.keys():
		texture = load(coin_image_paths[value])

	if coin_image:
		coin_image.texture = texture
