extends Node2D

@export var cell_block: PackedScene
@export var color_block: PackedScene

@onready var block_container = $UI/BlockContainer

@onready var new_block_cell_left: Panel = $UI/NewColorBlocks/ColorRect
@onready var new_block_cell_right: Panel = $UI/NewColorBlocks/ColorRect2

@onready var block_for_drop_1 = $UI/NewColorBlocks/ColorRect/Block
@onready var block_for_drop_2 = $UI/NewColorBlocks/ColorRect2/Block2
@onready var level_title: Control = $UI/LevelTitle

@onready var goal_colors_container: Control = $UI/GoalColorController
@onready var booster_ui: HBoxContainer = $UI/BoosterUI
@onready var new_color_blocks: Control = $UI/NewColorBlocks
@onready var booster_panel: HBoxContainer = $UI/Boosters

@onready var hammer_button: TextureButton = $UI/Boosters/Hammer
@onready var bomb_button: TextureButton = $UI/Boosters/Bomb
@onready var shuffle_button: TextureButton = $UI/Boosters/Shuffle


var BLOCK_ARR: Array
var current_level: Array = []
var _state: EState
var check_match_count: int = 0
var current_booster: Booster


enum EState {
	PLAY,
	BOOSTER,
}


func _ready() -> void:
	for booster_btn in booster_panel.get_children():
		booster_btn.count = Player.get_booster_count(booster_btn.booster.type)

	_restart_level()

	Gui.show_level_ui()
	Gui.restart_level.connect(_restart_level)
	Gui.next_level.connect(_next_level)


func _set_state(value: EState) -> void:
	_state = value

	match value:
		EState.PLAY:
			_hide_booster_ui()
			_demake_all_color_blocks_button()
		EState.BOOSTER:
			_set_booster_ui()
			_show_booster_ui()
			_make_all_color_blocks_button()


func _next_level() -> void:
	LevelManager.current_level += 1
	Player.set_value("current_level", LevelManager.current_level)
	Player.save_data()
	_restart_level()


func _restart_level() -> void:
	BLOCK_ARR = []

	for i in block_container.get_children():
		block_container.remove_child(i)

	LevelManager.is_prev_gameover = false
	var goal_colors_value = LevelManager.get_target_colors()
	EventBus.goals_changed.emit(goal_colors_value)
	goal_colors_container.set_colors(goal_colors_value)

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
						new_block_cell_left.add_child(buff)
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
						new_block_cell_right.add_child(buff)
						buff.create_random_color()
						block_for_drop_2 = buff
						update_level()
						check_matches(count / 6, count % 6)
						drop = true

					break
				count += 1

			if drop == false:
				block_for_drop_1.button_up()
				block_for_drop_1.position = Vector2(-35, -32)
				block_for_drop_2.button_up()
				block_for_drop_2.position = Vector2(-35, -32)


func _update_ui() -> void:
	level_title.level_value = LevelManager.current_level + 1


func move_node(node: Node, new_parent: Node):
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	node.z_index = 0
	node.position = Vector2(-50, -50)


func _make_all_color_blocks_button() -> void:
	for i in block_container.get_children():
		if i.active and not i.can_drop_block:
			var color_block = i.get_child(-1)
			color_block.set_is_button(true)


func _demake_all_color_blocks_button() -> void:
	for i in block_container.get_children():
		if i.active and not i.can_drop_block:
			var color_block = i.get_child(-1)
			color_block.set_is_button(false)


func create_level() -> void:
	current_level = LevelManager.get_current_level()

	for i in block_container.get_children():
		block_container.remove_child(i)

	for i in range(current_level.size()):
		for j in range(current_level[i].size()):
			var buff = cell_block.instantiate()
			buff.level_position.x = j
			buff.level_position.y = i

			var current_level_cell = current_level[i][j]
			if current_level_cell != LevelData.EMPTY_CELL:
				block_container.add_child(buff)

				if current_level[i][j] != LevelData.FREE_CELL:
					var buff1 = color_block.instantiate()
					buff1.pressed.connect(_on_color_block_pressed)
					buff.not_can_drop()
					buff.add_child(buff1)
					buff1.get_color_block(current_level[i][j])

			elif current_level[i][j] == LevelData.EMPTY_CELL:
				block_container.add_child(buff)
				buff.set_active(false)

	block_container.anchors_preset = Control.PRESET_CENTER

	update_level()


func _on_color_block_pressed(block: Node) -> void:
	# работает только во время использования бустера

	if _state == EState.BOOSTER:
		if current_booster.type == Booster.EType.HAMMER:
			block.colors = LevelData.FREE_CELL
			block.remove_block()
			_set_state(EState.PLAY)
			EventBus.booster_used.emit(current_booster.type)
		elif current_booster.type == Booster.EType.BOMB:
			var cell_pos = block.get_parent().level_position

			# запустить анимацию падения бомбы _здесь_

			# Ждём когда пройдёт анимация падения бомбы
			await Utils.timeout(0.2)

			# удаляем указанный блок
			block.colors = LevelData.FREE_CELL
			block.remove_block()

			# запускаем удаление плиток соседей
			await bomb_explode_neighbours(cell_pos)
			_set_state(EState.PLAY)
			EventBus.booster_used.emit(current_booster.type)


func bomb_explode_neighbours(pos: Vector2i) -> void:
	var neighbours = [
		Vector2i(-1, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(1, -1),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, -1),
		Vector2i(0, 1),
	]

	var level_height = LevelManager.get_current_level().size()
	var level_width = LevelManager.get_current_level()[0].size()

	for side in neighbours:
		var n_pos = side + pos

		if n_pos.x >= 0 and n_pos.x < level_width - 1 and n_pos.y >= 0 and n_pos.y < level_height - 1:
			var cur_level_cell = current_level[n_pos.y][n_pos.x]
			if cur_level_cell == LevelData.EMPTY_CELL:
				continue

			current_level[n_pos.y][n_pos.x][1] = 0
			var _idx = Utils.get_index_by_pos(n_pos, level_width)
			var _cell = block_container.get_child(_idx)

			var _block = _cell.get_color_block()
			var level_cell = current_level[n_pos.x][n_pos.y]
			if _block != null:
				_block.update_block(0, "up")

	update_level()
	await Utils.timeout(0.2)


func shuffle() -> void:
	prints("shuffle booster")

	var _non_empty_cells = LevelManager.get_non_empty_cells()
	var _positions: Array
	var _cell_data: Array

	for i in _non_empty_cells:
		if i.colors == LevelData.ADS_CELL:
			continue

		_positions.push_back(i.position)
		_cell_data.push_back(i.colors)

	_cell_data.shuffle()
	for i in _cell_data.size():
		var _colors = _cell_data[i]
		var pos = _positions[i]
		current_level[pos.y][pos.x] = _colors
		var cell_block = BLOCK_ARR[Utils.get_index_by_pos(pos, 6)]
		var _color_block = cell_block.get_color_block()
		if _color_block:
			_color_block.colors = _colors
			_color_block.set_reate_compain(_colors)

	for i in _positions:
		check_matches(i.x, i.y)


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


func check_matches(x: int, y: int) -> void:
	prints("check_matches")

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
						EventBus.goals_changed.emit(goal_colors_container.colors)
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
						EventBus.goals_changed.emit(goal_colors_container.colors)
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
		LevelManager.is_prev_gameover = true
		EventBus.goals_changed.emit(goal_colors_container.colors)
		EventBus.game_over.emit()


func check_level_complete() -> void:
	if not goal_colors_container.has_items():
		EventBus.coins_changed.emit(10 + Player.get_value("coins"))
		EventBus.level_complete.emit(LevelManager.current_level)


func _set_booster_ui() -> void:
	booster_ui.booster = current_booster
	booster_ui._update_ui()


func _on_booster_button_pressed(booster: Booster) -> void:
	current_booster = booster
	var booster_count = Player.get_booster_count(booster.type)
	if booster_count == 0:
		prints("show ads", booster)
	else:
		_set_state(EState.BOOSTER)


func _on_hammer_pressed() -> void:
	prints("hammer pressed")
	_on_booster_button_pressed(hammer_button.booster)


func _on_bomb_pressed() -> void:
	prints("bomb pressed")
	_on_booster_button_pressed(bomb_button.booster)


func _on_shuffle_pressed() -> void:
	prints("shuffle pressed")
	_on_booster_button_pressed(shuffle_button.booster)


func _on_booster_ui_cancel() -> void:
	_hide_booster_ui()


func _show_booster_ui() -> void:
	new_color_blocks.hide()
	booster_panel.hide()
	booster_ui.show()


func _hide_booster_ui() -> void:
	new_color_blocks.show()
	booster_panel.show()
	booster_ui.hide()


func _on_booster_ui_use_pressed() -> void:
	await shuffle()
	_set_state(EState.PLAY)
	EventBus.booster_used.emit(current_booster.type)
