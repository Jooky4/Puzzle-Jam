@tool
extends Control

enum EType {
	MINI,
	START,
	BEST,
	BIG,
}

enum EDiscount {
	DISCOUNT_10,
	#DISCOUNT_20,
	DISCOUNT_30,
	DISCOUNT_40,
	DISCOUNT_50,
}

@export var type: EType
@export var discount: EDiscount
@export var booster_count: int
@export var price: int
@export var currency_char: String
@export var coins_count: int

@export var mini_bg: Texture2D
@export var start_bg: Texture2D
@export var best_bg: Texture2D
@export var big_bg: Texture2D

@export var mini_fg: Texture2D
@export var start_fg: Texture2D
@export var best_fg: Texture2D
@export var big_fg: Texture2D


@export var coins500: Texture2D
@export var coins2000: Texture2D
@export var coins5000: Texture2D
@export var coins10000: Texture2D

@onready var texture_aliases = {
	EType.MINI: {
		"title": "Мини",
		"font_size": 42,
		"bg": mini_bg,
		"fg": mini_fg,
		"discount_color": 0,
	},
	EType.START: {
		"title": "Стартовый",
		"font_size": 33,
		"bg": start_bg,
		"fg": start_fg,
		"discount_color": 1,
	},
	EType.BEST: {
		"title": "Выгодный",
		"font_size": 33,
		"bg": best_bg,
		"fg": best_fg,
		"discount_color": 2,
	},
	EType.BIG: {
		"title": "Большой",
		"font_size": 33,
		"bg": big_bg,
		"fg": big_fg,
		"discount_color": 3,
	},
}

var discount_text_bind = {
	EDiscount.DISCOUNT_10: "10%",
	EDiscount.DISCOUNT_30: "30%",
	EDiscount.DISCOUNT_40: "40%",
	EDiscount.DISCOUNT_50: "50%",
}

@onready var coins_count_aliases = {
	500: coins500,
	2000: coins2000,
	5000: coins5000,
	10000: coins10000,
}

@onready var background: TextureRect = %Background
@onready var head_background: TextureRect = %HeadBackground
@onready var head_background_big: TextureRect = %HeadBackgroundBig

@onready var head_label: Label = %HeadLabel
@onready var discount_flag: Control = $Background/DiscountFlag

# лейблы количества бустеров
@onready var booster_count_label1: Label = $Background/Boosters/Label
@onready var booster_count_label2: Label = $Background/Boosters/Label2
@onready var booster_count_label3: Label = $Background/Boosters/Label3

@onready var booster_icons_common: TextureRect = $Background/Boosters/BoosterCommon
@onready var booster_icons_big: TextureRect = $Background/Boosters/BoosterBig
@onready var price_label: Label = %PriceLabel

@onready var coins_image: TextureRect = %CoinsImage
@onready var big_coins_image: TextureRect = %BigCoinsImage


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	var cur_texture = texture_aliases[type]

	if price_label:
		price_label.text = str(price) + currency_char

	if background:
		background.texture = cur_texture.bg

	if head_background:
		head_background_big.visible = type == EType.BIG
		head_background.visible = type != EType.BIG
		head_background.texture = cur_texture.fg

	if head_label:
		head_label.text = cur_texture.title
		head_label.label_settings.font_size = cur_texture.font_size

	if discount_flag:
		var _discount_text = discount_text_bind[discount]
		discount_flag.text = _discount_text
		discount_flag.color = cur_texture.discount_color

	if booster_count_label1:
		booster_count_label1.text = str(booster_count)
		booster_count_label2.text = str(booster_count)
		booster_count_label3.text = str(booster_count)

	if booster_icons_common:
		booster_icons_common.visible = type != EType.BIG
		booster_icons_big.visible = type == EType.BIG

	if coins_image:
		big_coins_image.visible = type == EType.BIG
		coins_image.visible = type != EType.BIG

		if coins_count in coins_count_aliases.keys():
			coins_image.texture = coins_count_aliases[coins_count]
