extends CanvasLayer

@onready var money_value_label: Control = %CoinCounter
@onready var home_button: TextureButton = %HomeButton
@onready var settings_button: TextureButton = %SettingsButton

@onready var game_over: Control = $GameOverModal/GameOver
@onready var level_complete: Control = $LevelCompleteModal/LevelComplete
@onready var buy_booster: Control = $BuyBoosterModal/BuyBooster

@onready var settings_modal: Panel = $SettingsModal
@onready var game_over_modal: Panel = $GameOverModal
@onready var level_complete_modal: Panel = $LevelCompleteModal
@onready var buy_booster_modal: Panel = $BuyBoosterModal

@onready var home_button_wrap: MarginContainer = $Top/HBoxContainer/MarginContainer2
@onready var settings_button_wrap: MarginContainer = $Top/HBoxContainer/MarginContainer

@onready var bottom_buttons: HBoxContainer = $Buttons
@onready var shop_button: TextureButton = %Shop
@onready var main_screen_button: TextureButton = %MainScreen
@onready var leaderboards_button: TextureButton = %Leaderboards


signal restart_level
signal next_level


enum EModal {
	Settings,
	Shop,
	LevelComplete,
	GameOver,
	BuyBooster
}

@onready var _modals: Dictionary[EModal, Node] = {
	EModal.Settings: settings_modal,
	EModal.LevelComplete: level_complete_modal,
	EModal.GameOver: game_over_modal,
	EModal.BuyBooster: buy_booster_modal,
}

func _ready() -> void:
	prints("gui ready")
	hide_all_modals()

	game_over.restart_level.connect(_on_game_over_restart_level)
	game_over.go_home.connect(_on_go_home_from_game_over)
	game_over.close.connect(_on_game_over_close)
	level_complete.next_level.connect(_on_level_complete_next_level)
	buy_booster.modal_close.connect(_on_buy_booster_close)

	EventBus.coins_changed.connect(_set_money)
	EventBus.game_over.connect(_on_game_over)
	EventBus.level_complete.connect(_on_level_complete)
	EventBus.buy_booster.connect(_on_buy_booster)
	EventBus.change_scene.connect(_on_change_scene)


func _on_game_over_close() -> void:
	hide_modal(EModal.GameOver)


func _on_buy_booster(booster: Booster) -> void:
	buy_booster.booster = booster
	show_modal(EModal.BuyBooster)


func _on_buy_booster_close() -> void:
	hide_modal(EModal.BuyBooster)


func _on_level_complete(level_number: int) -> void:
	# TODO: здесь можно на основе номера уровня начислить соотв. награду
	level_complete.reward = Config.COINS_FOR_COMPLETE_LEVEL

	level_complete.update()
	level_complete.play_animation()


	show_modal(EModal.LevelComplete)


func _on_game_over() -> void:
	SFX.play_sound("defeat")
	show_modal(EModal.GameOver)


func _on_game_over_restart_level() -> void:
	hide_modal(EModal.GameOver)
	restart_level.emit()


func _on_level_complete_next_level() -> void:
	hide_modal(EModal.LevelComplete)
	next_level.emit()


func _on_settings_close_button_pressed() -> void:
	hide_modal(EModal.Settings)


func _on_settings_button_pressed() -> void:
	SFX.play_sound("click")
	show_modal(EModal.Settings)


func _set_money(value: int) -> void:
	money_value_label.value = value


func _on_add_money_button_pressed() -> void:
	show_modal(EModal.Shop)


func _on_shop_close_button_pressed() -> void:
	hide_modal(EModal.Shop)


# -- MODALS --
func show_modal(modal_name: EModal) -> void:
	for name in _modals:
		if name == modal_name:
			_modals[name].show()
		else:
			_modals[name].hide()


func hide_modal(modal_name: EModal) -> void:
	if modal_name in _modals:
		_modals[modal_name].hide()


func hide_all_modals() -> void:
	for name in _modals:
		_modals[name].hide()


func _on_go_home_from_game_over() -> void:
	hide_all_modals()
	SFX.play_sound("click")
	ChangeScene.to("menu")
	# TODO: после GameOver поменять надпись кнопки на главном экране "Попробовать ещё раз"


func _on_home_button_pressed() -> void:
	SFX.play_sound("click")
	ChangeScene.to("menu")


func show_level_ui() -> void:
	home_button_wrap.show()
	settings_button_wrap.hide()


func show_main_menu_ui() -> void:
	home_button_wrap.hide()
	settings_button_wrap.show()
	money_value_label.show()


func hide_default_ui() -> void:
	if home_button:
		home_button_wrap.hide()

	if settings_button_wrap:
		settings_button_wrap.hide()

	if money_value_label:
		money_value_label.hide()


func show_default_ui() -> void:
	if home_button:
		home_button_wrap.hide()

	if settings_button_wrap:
		settings_button_wrap.hide()


func _on_settings_modal_modal_close() -> void:
	hide_modal(EModal.Settings)


func _on_shop_toggled(toggled_on: bool) -> void:
	if toggled_on:
		ChangeScene.to("shop")


func _on_main_screen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		ChangeScene.to("menu")


func _on_leaderboards_toggled(toggled_on: bool) -> void:
	if toggled_on:
		ChangeScene.to("leaderboard")


func _on_change_scene(scene_name: String) -> void:
	bottom_buttons.show()
	shop_button.get_node("VBoxContainer/Label").visible = false
	main_screen_button.get_node("VBoxContainer/Label").visible = false
	leaderboards_button.get_node("VBoxContainer/Label").visible = false

	if scene_name == "game":
		bottom_buttons.hide()

	if scene_name == "shop":
		shop_button.button_pressed = true
		shop_button.get_node("VBoxContainer/Label").visible = true

	if scene_name == "menu":
		main_screen_button.button_pressed = true
		main_screen_button.get_node("VBoxContainer/Label").visible = true

	if scene_name == "leaderboard":
		leaderboards_button.button_pressed = true
		leaderboards_button.get_node("VBoxContainer/Label").visible = true
