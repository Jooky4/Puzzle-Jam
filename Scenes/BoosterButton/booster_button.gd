@tool
extends TextureButton


@export var booster: Booster

@export var count: int: set = _set_count
@export var locked_text: String

@onready var plus_icon: TextureRect = $Control/PlusIcon
@onready var count_background: PanelContainer = $Control/CountBackground
@onready var count_label: Label = $Control/CountBackground/Label

@onready var unlocked_control: Control = $Control
@onready var icon: TextureRect = $Control/Icon
@onready var locked_label: Label = $LockedLabel


func _ready() -> void:
	_update_ui()
	EventBus.player_data_changed.connect(_on_player_data_changed)


func _on_player_data_changed(key: String) -> void:
	var cur_buster_name = Player.booster_name[booster.type]
	if key == cur_buster_name:
		count = Player.get_booster_count(booster.type)


func _set_count(value: int) -> void:
	count = max(value, 0)

	if count_label:
		_update_ui()


func _update_ui() -> void:
	count_label.text = str(count)
	plus_icon.visible = count == 0
	count_background.visible = count > 0

	unlocked_control.visible = not disabled

	icon.texture = booster.icon

	locked_label.text = locked_text
	locked_label.visible = disabled
