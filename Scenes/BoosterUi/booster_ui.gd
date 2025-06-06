extends HBoxContainer


@export var booster: Booster

signal cancel
signal use

@onready var icon: TextureRect = $Icon
@onready var use_button: TextureButton = $UseButton
@onready var label: Label = $Label


func _update_ui() -> void:
	icon.texture = booster.icon

	use_button.visible = booster.type == Booster.EType.SHUFFLE
	label.visible = booster.type != Booster.EType.SHUFFLE
	label.text = booster.get_description()


func _on_cancel_button_pressed() -> void:
	cancel.emit()


func _on_use_button_pressed() -> void:
	use.emit()
