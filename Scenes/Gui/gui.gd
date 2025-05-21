extends CanvasLayer

@export var main_menu_scene: PackedScene

@onready var money_value_label: Control = %CoinCounter
@onready var home_button: TextureButton = %HomeButton
@onready var settings_button: TextureButton = %SettingsButton

@onready var game_over: Control = $GameOverModal/GameOver
@onready var level_complete: Control = $LevelCompleteModal/LevelComplete

@onready var settings_modal: Panel = $SettingsModal
@onready var shop_modal: Panel = $ShopModal
@onready var game_over_modal: Panel = $GameOverModal
@onready var level_complete_modal: Panel = $LevelCompleteModal

@onready var home_button_wrap: MarginContainer = $Top/HBoxContainer/MarginContainer2
@onready var settings_button_wrap: MarginContainer = $Top/HBoxContainer/MarginContainer

signal restart_level
signal next_level


enum EModal {
	Settings,
	Shop,
	LevelComplete,
	GameOver,
}

@onready var _modals: Dictionary[EModal, Node] = {
	EModal.Settings: settings_modal,
	EModal.Shop: shop_modal,
	EModal.LevelComplete: level_complete_modal,
	EModal.GameOver: game_over_modal,
}

func _ready() -> void:
	hide_all_modals()

	game_over.restart_level.connect(_on_game_over_restart_level)
	game_over.go_home.connect(_on_go_home_from_game_over)
	level_complete.next_level.connect(_on_level_complete_next_level)

	EventBus.coins_changed.connect(_set_money)
	EventBus.game_over.connect(_on_game_over)
	EventBus.level_complete.connect(_on_level_complete)


func _on_level_complete(level_number: int) -> void:
	level_complete.update()
	level_complete.play_animation()
	show_modal(EModal.LevelComplete)


func _on_game_over() -> void:
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
	get_tree().change_scene_to_packed(main_menu_scene)
	# TODO: после GameOver поменять надпись кнопки на главном экране "Попробовать ещё раз"


func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func show_level_ui() -> void:
	home_button_wrap.show()
	settings_button_wrap.hide()


func show_main_menu_ui() -> void:
	home_button_wrap.hide()
	settings_button_wrap.show()


func _on_settings_modal_modal_close() -> void:
	hide_modal(EModal.Settings)
