extends Control

@onready var arr_blocs = [$Small_block_1, $Small_block_2, $Small_block_3, $Small_block_4]
@onready var BLOCK_COLORS = [0, 0, 0, 0]

@onready var can_take_block : bool = true
@onready var follow_mouse : bool = false
@onready var button = $Button

func _process(_delta):
	if follow_mouse:
		global_position = get_global_mouse_position() - Vector2(52.5, 52.5)

func get_color_block(arr_color) -> void:
	can_take_block = false
	button.visible = false
	BLOCK_COLORS = arr_color
	$Small_block_1/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[0]]
	$Small_block_2/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[1]]
	$Small_block_3/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[2]]
	$Small_block_4/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[3]]

	set_reate_compain(BLOCK_COLORS)

func drop_block() -> void:
	can_take_block = false
	follow_mouse = false
	button.visible = false

func are_all_elements_equal(arr: Array) -> bool:
	var first_element = arr[0]
	for element in arr:
		if element != first_element:
			return false
	return true

func _on_button_button_down() -> void:
	if can_take_block:
		follow_mouse = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func button_up() -> void:
	follow_mouse = false
	button.mouse_filter = Control.MOUSE_FILTER_PASS

func create_random_color() -> void:
	var keys = LevelManager.COLOR_BLOCK.keys()
	var arr_color = []

	arr_color.append(keys[randi() % keys.size()])
	arr_color.append(keys[randi() % keys.size()])

	var third_color = keys[randi() % keys.size()]
	while third_color == arr_color[0] and third_color == arr_color[1]:
		third_color = keys[randi() % keys.size()]
	arr_color.append(third_color)

	var fourth_color = keys[randi() % keys.size()]
	while (fourth_color == arr_color[0] and fourth_color == arr_color[1]) or \
		  (fourth_color == arr_color[0] and fourth_color == arr_color[2]) or \
		  (fourth_color == arr_color[1] and fourth_color == arr_color[2]):
		fourth_color = keys[randi() % keys.size()]
	arr_color.append(fourth_color)

	arr_color.shuffle()

	$Small_block_1/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[0]]
	$Small_block_2/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[1]]
	$Small_block_3/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[2]]
	$Small_block_4/ColorRect.color = LevelManager.COLOR_BLOCK[arr_color[3]]
	BLOCK_COLORS = arr_color
	set_reate_compain(BLOCK_COLORS)

func set_reate_compain(arr_color) -> void:
	if are_all_elements_equal(arr_color):
		arr_blocs[1].visible = false
		arr_blocs[2].visible = false
		arr_blocs[3].visible = false
		arr_blocs[0].anchors_preset = PRESET_FULL_RECT

	else:
		if arr_color[0] == arr_color[1]:
			arr_blocs[1].visible = false
			arr_blocs[0].custom_minimum_size = Vector2(105, 50)

		if arr_color[2] == arr_color[3]:
			arr_blocs[3].visible = false
			arr_blocs[2].custom_minimum_size = Vector2(105, 50)

		if arr_color[0] == arr_color[2]:
			arr_blocs[2].visible = false
			arr_blocs[0].custom_minimum_size = Vector2(50, 105)

		if arr_color[1] == arr_color[3]:
			arr_blocs[3].visible = false
			arr_blocs[1].custom_minimum_size = Vector2(50, 105)
