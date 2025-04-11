extends Node2D

@onready var EMPTY_BLOCK = preload("res://Scenes/Block/empty_block.tscn")
@onready var COLOR_BLOCK = preload("res://Scenes/Block/block.tscn")
@onready var block_container = $UI/GridContainer

@onready var block_for_drop_1 = $UI/VBoxContainer/ColorRect/Block
@onready var block_for_drop_2 = $UI/VBoxContainer/ColorRect2/Block2

var BLOCK_ARR : Array
var CURRENT_LEVEL_MATRIX : Array = []

func _ready() -> void:
	create_level()
	BLOCK_ARR = block_container.get_children()
	block_for_drop_1.create_random_color()
	block_for_drop_2.create_random_color()

func _input(event):
	var drop = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			var count = 0
			for i in block_container.get_children():
				if i.select:
					if block_for_drop_1.follow_mouse:
						block_for_drop_1.drop_block()
						i.add_block()
						move_node(block_for_drop_1, i)
						var buff = COLOR_BLOCK.instantiate()
						$UI/VBoxContainer/ColorRect.add_child(buff)
						buff.create_random_color()
						block_for_drop_1 = buff
						update_lvl_matrix()
						check_matches(count / 6, count % 6)
						drop = true

					elif block_for_drop_2.follow_mouse:
						block_for_drop_2.drop_block()
						i.add_block()
						move_node(block_for_drop_2, i)
						var buff = COLOR_BLOCK.instantiate()
						$UI/VBoxContainer/ColorRect2.add_child(buff)
						buff.create_random_color()
						block_for_drop_2 = buff
						update_lvl_matrix()
						check_matches(count / 6, count % 6)
						drop = true
					break
				count += 1

			if drop == false:
				block_for_drop_1.button_up()
				block_for_drop_1.global_position = $UI/VBoxContainer/ColorRect.global_position + Vector2(23, 23)
				block_for_drop_2.button_up()
				block_for_drop_2.global_position = $UI/VBoxContainer/ColorRect2.global_position + Vector2(23, 23)

func move_node(node: Node, new_parent: Node):
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	node.global_position = new_parent.global_position

func create_level() -> void:
	CURRENT_LEVEL_MATRIX = LevelManager.get_current_level_setup()

	for i in range(CURRENT_LEVEL_MATRIX.size()):
		for j in range(CURRENT_LEVEL_MATRIX[i].size()):
			var buff = EMPTY_BLOCK.instantiate()
			if CURRENT_LEVEL_MATRIX[i][j] != [-1, -1, -1, -1]:
				block_container.add_child(buff)

				if CURRENT_LEVEL_MATRIX[i][j] != [0, 0, 0, 0]:
					var buff1 = COLOR_BLOCK.instantiate()
					buff.not_can_drop()
					buff.add_child(buff1)
					buff1.get_color_block(CURRENT_LEVEL_MATRIX[i][j])

			elif CURRENT_LEVEL_MATRIX[i][j] == [-1, -1, -1, -1]:
				buff.set_not_active()
				block_container.add_child(buff)

	block_container.anchors_preset = Control.PRESET_CENTER
	update_lvl_matrix()

func update_lvl_matrix() -> void:
	var count = 0
	for i in block_container.get_children():
		if i.active:
			if i.get_child_count() != 1:
				for j in i.get_children():
					if "Block" in j.name:
						CURRENT_LEVEL_MATRIX[count / 6][count % 6] = j.BLOCK_COLORS
			else:
				CURRENT_LEVEL_MATRIX[count / 6][count % 6] = [0, 0, 0, 0]
		else:
			CURRENT_LEVEL_MATRIX[count / 6][count % 6] = [-1, -1, -1, -1]
		count += 1

func check_matches(x: int, y: int) -> void:
	var have_coincidence : bool = false
	var current_cell = CURRENT_LEVEL_MATRIX[x][y]
	if current_cell[0] == -1:
		return  # Неактивная ячейка

	var connections = [
		[
			[x-1, y, 2],
			[x, y-1, 1]
		],
		[
			[x-1, y, 3],
			[x, y+1, 0]
		],
		[
			[x+1, y, 0],
			[x, y-1, 3]
		],
		[
			[x+1, y, 1],
			[x, y+1, 2]
		]
	]

	for side in 4:
		var current_color = current_cell[side]
		if current_color <= 0:
			continue

		for connection in connections[side]:
			var nx = connection[0]
			var ny = connection[1]
			var neighbor_side = connection[2]

			if nx < 0 or ny < 0 or nx >= len(CURRENT_LEVEL_MATRIX) or ny >= len(CURRENT_LEVEL_MATRIX[0]):
				continue

			var neighbor_cell = CURRENT_LEVEL_MATRIX[nx][ny]
			var neighbor_color = neighbor_cell[neighbor_side]

			if neighbor_color == current_color:
				#print("Совпадение найдено:")
				#print("Основной блок: позиция (%d, %d), сторона %d, цвет %d" % [x, y, side, current_color])
				#print("Соседний блок: позиция (%d, %d), сторона %d, цвет %d" % [nx, ny, neighbor_side, neighbor_color], "   ", neighbor_cell)
				current_cell[side] = 0
				neighbor_cell[neighbor_side] = 0
				CURRENT_LEVEL_MATRIX[y][x] = current_cell
				CURRENT_LEVEL_MATRIX[ny][nx] = neighbor_cell

				for j in BLOCK_ARR[((x * 6) + y)].get_children():
					if "Block" in j.name:
						if x == nx and y > ny:
							j.update_block(current_color, "left")
						elif x == nx and y < ny:
							j.update_block(current_color, "right")
						elif x > nx and y == ny:
							j.update_block(current_color, "up")
						elif x < nx and y == ny:
							j.update_block(current_color, "down")

				for j in BLOCK_ARR[((nx * 6) + ny)].get_children():
					if "Block" in j.name:
						if x == nx and y > ny:
							j.update_block(neighbor_color, "right")
						elif x == nx and y < ny:
							j.update_block(neighbor_color, "left")
						elif x > nx and y == ny:
							j.update_block(neighbor_color, "down")
						elif x < nx and y == ny:
							j.update_block(neighbor_color, "up")

				update_lvl_matrix()
				await get_tree().create_timer(1).timeout
				check_matches(nx, ny)
				have_coincidence = true
				break
	if have_coincidence:
		check_matches(x, y)
