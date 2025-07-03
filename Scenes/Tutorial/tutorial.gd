extends Node2D


@onready var pointer: Node2D = $Pointer
@onready var drag_indicator: Sprite2D = $Pointer/DragIndicator

var _is_stopped: bool = false
var _t: Tween

func _ready() -> void:
	hide_pointer()
	hide_drag()
	_t = create_tween()
	_t.tween_property(self, "modulate", Color(1,1,1), 0.01)


func show_pointer() -> void:
	pointer.show()


func hide_pointer() -> void:
	pointer.hide()


func move_pointer_to(pos: Vector2) -> Tween:
	if _t:
		_t.stop()
		_t.kill()

	_t = create_tween()
	_t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_t.tween_property(pointer, "position", pos, 1)
	_t.play()
	return _t


func run() -> void:
	_is_stopped = false


func stop() -> void:
	_is_stopped = true
	_t.stop()
	_t.kill()
	hide_pointer()


func show_drag() -> void:
	drag_indicator.show()


func hide_drag() -> void:
	drag_indicator.hide()


func run_level_01(pos1, pos2) -> void:
	pointer.position = pos1
	show_pointer()
	await Utils.timeout(0.2)
	show_drag()
	await Utils.timeout(0.4)
	await move_pointer_to(pos2).finished
	await Utils.timeout(0.5)
	hide_drag()
	await Utils.timeout(0.2)
	hide_pointer()

	if not _is_stopped:
		await Utils.timeout(0.4)
		run_level_01(pos1, pos2)


func click_button(start_pos: Vector2, pos: Vector2) -> void:
	# отодвигаем указатель от позиции
	pointer.position = start_pos
	show_pointer()
	await Utils.timeout(0.2)

	if _is_stopped:
		return

	await move_pointer_to(pos).finished
	await Utils.timeout(0.2)
	show_drag()
	await Utils.timeout(0.3)
	hide_pointer()
	hide_drag()


func run_click_hammer(pos1, pos2) -> void:
	prints("run click hammer", _is_stopped)
	await click_button(pos1, pos2)

	if _is_stopped:
		prints("run click hammer stopped")
		return
	else:
		prints("run click hammer again")
		await Utils.timeout(0.4)
		await run_click_hammer(pos1, pos2)
		return
