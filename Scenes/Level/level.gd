extends Node2D

@export var cell_block: PackedScene
@export var color_block: PackedScene

@onready var block_container = $UI/GridContainer

@onready var block_for_drop_1 = $UI/VBoxContainer/ColorRect/Block
@onready var block_for_drop_2 = $UI/VBoxContainer/ColorRect2/Block2
@onready var level_label: Label = $UI/PanelContainer/Label

@onready var goal_colors_container: Control = $UI/GoalColorController

var BLOCK_ARR: Array
var current_level: Array = []

func _ready() -> void:
	_restart_level()

	Gui.show_level_ui()
	Gui.restart_level.connect(_restart_level)
	Gui.next_level.connect(_next_level)


func _next_level() -> void:
	LevelManager.current_level += 1
	Player.set_value("current_level", LevelManager.current_level)
	Player.save_data()
	_restart_level()


func _restart_level() -> void:
	BLOCK_ARR = []

	for i in block_container.get_children():
		block_container.remove_child(i)

	goal_colors_container.set_colors(LevelManager.get_target_colors())


	create_level()
	BLOCK_ARR = block_container.get_children()
	block_for_drop_1.create_random_color()
	block_for_drop_2.create_random_color()
	_update_ui()


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
						var buff = color_block.instantiate()
						$UI/VBoxContainer/ColorRect.add_child(buff)
						buff.create_random_color()

						block_for_drop_1 = buff
						update_level()
						check_matches(count / 6, count % 6)
						drop = true

					elif block_for_drop_2.follow_mouse:
						block_for_drop_2.drop_block()
						i.add_block()
						move_node(block_for_drop_2, i)
						var buff = color_block.instantiate()
						$UI/VBoxContainer/ColorRect2.add_child(buff)
						buff.create_random_color()
						block_for_drop_2 = buff
						update_level()
						check_matches(count / 6, count % 6)
						drop = true

					break
				count += 1

			if drop == false:
				block_for_drop_1.button_up()
				block_for_drop_1.global_position = $UI/VBoxContainer/ColorRect.global_position + Vector2(23, 23)
				block_for_drop_2.button_up()
				block_for_drop_2.global_position = $UI/VBoxContainer/ColorRect2.global_position + Vector2(23, 23)


func _update_ui() -> void:
	level_label.text = "Уровень: %d" % (LevelManager.current_level + 1)


func move_node(node: Node, new_parent: Node):
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	node.z_index = 0
	node.global_position = new_parent.global_position


func create_level() -> void:
	current_level = LevelManager.get_current_level()

	for i in block_container.get_children():
		block_container.remove_child(i)

	for i in range(current_level.size()):
		for j in range(current_level[i].size()):
			var buff = cell_block.instantiate()
			if current_level[i][j] != LevelData.EMPTY_CELL:
				block_container.add_child(buff)

				if current_level[i][j] != LevelData.FREE_CELL:
					var buff1 = color_block.instantiate()
					buff.not_can_drop()
					buff.add_child(buff1)
					buff1.get_color_block(current_level[i][j])

			elif current_level[i][j] == LevelData.EMPTY_CELL:
				block_container.add_child(buff)
				buff.set_active(false)

	block_container.anchors_preset = Control.PRESET_CENTER

	update_level()


func update_level() -> void:
	# Обновляет данные текущего уровня

	var count = 0
	for cell in block_container.get_children():
		if cell.is_active():
			if cell.get_child_count() != 1:
				for j in cell.get_children():
					if "Block" in j.name:
						current_level[count / 6][count % 6] = j.colors
			else:
				current_level[count / 6][count % 6] = LevelData.FREE_CELL
		else:
			var row = count / 6
			var col = count % 6
			current_level[row][col] = LevelData.EMPTY_CELL

		count += 1


var check_match_count: int = 0

func check_matches(x: int, y: int) -> void:
	#await Utils.timeout(1)
	check_match_count += 1
	var have_match: bool = false
	var current_cell = current_level[x][y]

	if current_cell == LevelData.EMPTY_CELL:
		return

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

	for side in 4: # from 0 to 3
		var current_color = current_cell[side]
		if current_color <= 0:
			continue

		for connection in connections[side]:
			var nx = connection[0]
			var ny = connection[1]

			# проверка выхода за границы поля
			if nx < 0 or ny < 0 or nx >= len(current_level) or ny >= len(current_level[0]):
				continue

			var neighbor_side = connection[2]
			var neighbor_cell = current_level[nx][ny]
			var neighbor_color = neighbor_cell[neighbor_side]

			if neighbor_color == current_color:
				#print("Совпадение найдено:")
				#print("Основной блок: позиция (%d, %d), сторона %d, цвет %d" % [x, y, side, current_color])
				#print("Соседний блок: позиция (%d, %d), сторона %d, цвет %d" % [nx, ny, neighbor_side, neighbor_color], "   ", neighbor_cell)
				current_cell[side] = 0
				neighbor_cell[neighbor_side] = 0
				current_level[y][x] = current_cell
				current_level[ny][nx] = neighbor_cell

				# обновляем цвета у текущей плитки
				for j in BLOCK_ARR[((x * 6) + y)].get_children():
					if "Block" in j.name:
						var direction: String

						if x == nx and y > ny:
							direction = "left"
						elif x == nx and y < ny:
							direction = "right"
						elif x > nx and y == ny:
							direction = "up"
						elif x < nx and y == ny:
							direction = "down"

						goal_colors_container.dec_color(current_color)
						j.update_block(current_color, direction)

				# обновляем цета у соседней плитки
				for j in BLOCK_ARR[((nx * 6) + ny)].get_children():
					if "Block" in j.name:
						var direction: String

						if x == nx and y > ny:
							direction = "right"
						elif x == nx and y < ny:
							direction = "left"
						elif x > nx and y == ny:
							direction = "down"
						elif x < nx and y == ny:
							direction = "up"

						goal_colors_container.dec_color(current_color)
						j.update_block(current_color, direction)

				update_level()
				check_matches(nx, ny)
				have_match = true
				break

	if have_match:
		check_matches(x, y)

	check_match_count -= 1

	if check_match_count < 1:
		update_level()
		check_level_complete()
		check_game_over()


func get_free_cell_count() -> int:
	var free_cell_count: int = 0

	for row in current_level:
		for cell in row:
			if cell == LevelData.FREE_CELL:
				free_cell_count += 1

	return free_cell_count


func check_game_over() -> void:
	if get_free_cell_count() == 0:
		Gui.show_modal(Gui.EModal.GameOver)


func check_level_complete() -> void:
	if not goal_colors_container.has_items():
		Player.set_value("money", 10 + Player.get_value("money"))
		Gui.show_modal(Gui.EModal.LevelComplete)
