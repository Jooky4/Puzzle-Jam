extends Control

@export var texture_list: Array[Texture2D]

@onready var arr_blocs = [$Small_block_1, $Small_block_2, $Small_block_3, $Small_block_4]
@onready var colors: Array = LevelData.FREE_CELL.duplicate(true)
@onready var debug_label: Label = $DebugLabel

@onready var can_take_block: bool = true
@onready var follow_mouse: bool = false
@onready var button = $Button

@onready var texture_binds = {
	10: texture_list[0],
	11: texture_list[1],
	12: texture_list[2],
	13: texture_list[3],
	14: texture_list[4],
	15: texture_list[5],
	16: texture_list[6],
	17: texture_list[7],
}

var count_block = 0

func _ready() -> void:
	if not OS.is_debug_build():
		debug_label.visible = false


func _to_string() -> String:
	return "<Block: %s colors: [%s]>" % [
			name,
			colors
		]


func _process(_delta):
	if follow_mouse:
		global_position = get_global_mouse_position() - Vector2(52.5, 52.5)

	debug_label.text = str("[%d, %d,\n%d, %d]" % colors)


func get_color_block(arr_color) -> void:
	can_take_block = false
	button.visible = false
	colors = arr_color

	#$Small_block_1/ColorRect.color = LevelData.COLORS[arr_color[0]]
	#$Small_block_2/ColorRect.color = LevelData.COLORS[arr_color[1]]
	#$Small_block_3/ColorRect.color = LevelData.COLORS[arr_color[2]]
	#$Small_block_4/ColorRect.color = LevelData.COLORS[arr_color[3]]

	prints("arr_color", arr_color)
	$Small_block_2/ColorRect.texture = texture_binds[arr_color[1]]
	$Small_block_3/ColorRect.texture = texture_binds[arr_color[2]]
	$Small_block_4/ColorRect.texture = texture_binds[arr_color[3]]
	$Small_block_1/ColorRect.texture = texture_binds[arr_color[0]]

	set_reate_compain(colors)
	#update_ui()


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
		z_index = 10
		follow_mouse = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func button_up() -> void:
	follow_mouse = false
	z_index = 0
	button.mouse_filter = Control.MOUSE_FILTER_PASS


func _fix_diagonal_colors(colors: Array) -> void:
	"""
	var example = [
		0, 1,
		1, 0
	]
	var example_result = [
		0, 0,
		1, 1
	]
	"""

	if colors[0] == colors[3]:
		var color1 = colors[0]
		var color2 = colors[1]
		colors[0] = color2
		colors[1] = color1

	if colors[1] == colors[2]:
		var color1 = colors[1]
		var color2 = colors[3]
		colors[1] = color2
		colors[3] = color1


func _create_random_color(used_colors: Array) -> Array:
	var chance_percent = randi_range(1, 100)
	var colors: Array

	used_colors.shuffle()

	if chance_percent <= 10:
		# один цвет
		var color = used_colors.pick_random()
		colors = [color, color, color, color]
	elif chance_percent > 15 and chance_percent <= 10 + 15:
		# два цвета
		colors = used_colors.slice(0, 2)
		colors.append_array(colors)
		colors.shuffle()
		_fix_diagonal_colors(colors)
	elif chance_percent > 10 + 15 and chance_percent <= 10 + 15 + 45:
		# три цвета
		colors = used_colors.slice(0, 3)
		var add_color = colors.pick_random()
		colors.push_back(add_color)
		colors.shuffle()
		_fix_diagonal_colors(colors)
	else:
		# четыре цвета
		colors = used_colors.slice(0, 4)
		# по идее, здесь не нужно. Все цвета уникальные
		# TODO: проверить
		_fix_diagonal_colors(colors)

	return colors


func create_random_color(used_colors: Array = []) -> void:
	if used_colors.size() == 0:
		used_colors = LevelManager.get_current_level_colors()

	var data = _create_random_color(used_colors)
	colors = data

	set_reate_compain(colors)
	#update_ui()


# TODO: remove
func old_create_random_color() -> void:
	var keys = LevelData.COLORS.keys()
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

	colors = arr_color
	set_reate_compain(colors)
	#update_ui()


func update_ui() -> void:
	# будущая замена set_reate_compain()
	var tails = [
		$Small_block_1/ColorRect,
		$Small_block_2/ColorRect,
		$Small_block_3/ColorRect,
		$Small_block_4/ColorRect,
	]

	for i in colors.size():
		var color = colors[i]
		var current_tail = tails[i]

		if color == 0:
			current_tail.color = Color.WHITE
			continue

		current_tail.color = LevelData.COLORS[color]


func set_reate_compain(arr_color) -> void:
	$Small_block_2/ColorRect.texture = texture_binds[arr_color[1]]
	$Small_block_3/ColorRect.texture = texture_binds[arr_color[2]]
	$Small_block_4/ColorRect.texture = texture_binds[arr_color[3]]
	$Small_block_1/ColorRect.texture = texture_binds[arr_color[0]]

	#$Small_block_1/ColorRect.color = LevelData.COLORS[arr_color[0]]
	#$Small_block_2/ColorRect.color = LevelData.COLORS[arr_color[1]]
	#$Small_block_3/ColorRect.color = LevelData.COLORS[arr_color[2]]
	#$Small_block_4/ColorRect.color = LevelData.COLORS[arr_color[3]]

	var full_w = 200
	var full_h = 200

	var half_w = 100
	var half_h = 100

	if are_all_elements_equal(arr_color):
		arr_blocs[0].visible = true
		arr_blocs[1].visible = false
		arr_blocs[2].visible = false
		arr_blocs[3].visible = false
		#create_tween().tween_property(
			#arr_blocs[0],
			#"custom_minimum_size",
			#Vector2(105, 105),
			#1
		#)
		arr_blocs[0].size = Vector2(full_w, full_h)
		count_block = 1

	else:
		if arr_color[0] == arr_color[1]:
			arr_blocs[0].visible = true
			arr_blocs[1].visible = false
			#create_tween().tween_property(arr_blocs[0], "custom_minimum_size", Vector2(105, 50), 1)
			arr_blocs[0].size = Vector2(full_w, half_h)

		if arr_color[2] == arr_color[3]:
			arr_blocs[2].visible = true
			arr_blocs[3].visible = false
			#create_tween().tween_property(arr_blocs[2], "custom_minimum_size", Vector2(105, 50), 1)
			arr_blocs[2].size = Vector2(full_w, half_h)

		if arr_color[0] == arr_color[2]:
			arr_blocs[0].visible = true
			arr_blocs[2].visible = false
			#create_tween().tween_property(arr_blocs[0], "custom_minimum_size", Vector2(50, 105), 1)
			arr_blocs[0].size = Vector2(half_w, full_h)

		if arr_color[1] == arr_color[3]:
			arr_blocs[1].visible = true
			arr_blocs[3].visible = false
			#create_tween().tween_property(arr_blocs[1], "custom_minimum_size", Vector2(50, 105), 1)
			arr_blocs[1].size = Vector2(half_w, full_h)

		var unique_dict = {}
		for color in arr_color:
			unique_dict[color] = true
		count_block = unique_dict.keys().size()

		if arr_blocs[0].visible and arr_blocs[1].visible and arr_blocs[2].visible and arr_blocs[3].visible:
			count_block = 4


func update_block(delete_color, direction) -> void:
	for i in range(colors.size()):
		if colors[i] == 0:
			if count_block == 1:
				colors = LevelData.FREE_CELL
				self.get_parent().free_block()
				self.queue_free()
				return

			elif count_block == 2:
				for k in colors:
					if colors.count(k) == 2:
						colors = [k, k, k, k]
						break
				break

			elif count_block == 3:
				for j in range(colors.size()):
					if colors[j] == delete_color:
						colors[j] = 0

				if colors[0] == 0 and colors[3] == 0:
					colors[0] = colors[1]
					colors[3] = colors[2]
				elif colors[1] == 0 and colors[2] == 0:
					colors[1] = colors[0]
					colors[2] = colors[3]
				elif colors[0] == 0 and colors[2] == 0:
					colors[0] = colors[1]
					colors[2] = colors[3]
				elif colors[1] == 0 and colors[3] == 0:
					colors[1] = colors[0]
					colors[3] = colors[2]
				elif colors[0] == 0 and colors[1] == 0:
					colors[0] = colors[2]
					colors[1] = colors[3]
				elif colors[1] == 0 and colors[2] == 0:
					colors[1] = colors[0]
					colors[2] = colors[3]
				elif colors[2] == 0 and colors[3] == 0:
					colors[2] = colors[0]
					colors[3] = colors[1]
				else:
					for k in range(colors.size()):
						if colors.count(colors[k]) == 1 and colors[k] != 0:
							colors[i] = colors[k]
							break
				break

			elif count_block == 4:
				if i == 0:
					if direction == "up":
						colors[i] = colors[2]
					elif direction == "left":
						colors[i] = colors[1]
				elif i == 1:
					if direction == "up":
						colors[i] = colors[3]
					elif direction == "right":
						colors[i] = colors[0]
				elif i == 2:
					if direction == "down":
						colors[i] = colors[0]
					elif direction == "left":
						colors[i] = colors[3]
				elif i == 3:
					if direction == "down":
						colors[i] = colors[1]
					elif direction == "right":
						colors[i] = colors[2]
				break

	#update_ui()
	set_reate_compain(colors)
