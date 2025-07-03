extends Node2D

@export var cell_block: PackedScene
@export var color_block: PackedScene


@onready var block_container = $UI/BlockContainer

@onready var new_block_cell_left: Panel = $UI/NewColorBlocks/ColorRect
@onready var new_block_cell_right: Panel = $UI/NewColorBlocks/ColorRect2

@onready var block_for_drop_1 = $UI/NewColorBlocks/ColorRect/ColorBlock2D
@onready var block_for_drop_2 = $UI/NewColorBlocks/ColorRect2/ColorBlock2D
@onready var level_title: Control = $UI/LevelTitle

@onready var goal_colors_container: Control = $UI/GoalColorController
@onready var booster_ui: HBoxContainer = $UI/BoosterUI
@onready var new_color_blocks: Control = $UI/NewColorBlocks
@onready var booster_panel: HBoxContainer = $UI/Boosters

@onready var hammer_button: TextureButton = $UI/Boosters/Hammer
@onready var bomb_button: TextureButton = $UI/Boosters/Bomb
@onready var shuffle_button: TextureButton = $UI/Boosters/Shuffle

@onready var hammer_animation: Node2D = $AnimationHammer
@onready var animation_bomb: Node2D = $AnimationBomb
@onready var tutorial: Node2D = $Tutorial

@onready var mobile_bg: TextureRect = $CanvasLayer/MobileBG
@onready var desktop_bg: Node2D = $DesktopBG


enum EState {
	PLAY,
	BOOSTER,
	CHECK,
	ADS,
}

# TODO: удалить. Использовать только block_container
var BLOCK_ARR: Array

# данные уровня
var current_level: Array = []
var _state: EState
var check_match_count: int = 0
var current_booster: Booster

var turns: int = 0
var _prev_turn: int = 0
var live_block_list: Array[ColorBlock]

var _current_cell_rewarded: Node
var pregenerated_color_blocks: Array

var _debug_var_1: bool = false
var leaderboard_options: Dictionary
var block_center_offset = Vector2(50, 50)

var _locks: Array


func _ready() -> void:
	if Bridge.device.type == "mobile":
		desktop_bg.hide()
		mobile_bg.show()
	else:
		desktop_bg.show()
		mobile_bg.hide()

	LevelManager.current_level = Player.get_value("current_level")
	for booster_btn in booster_panel.get_children():
		booster_btn.count = Player.get_booster_count(booster_btn.booster.type)

	_restart_level()

	Gui.show_level_ui()
	Gui.restart_level.connect(_restart_level)
	Gui.next_level.connect(_next_level)
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))
	EventBus.buy_free_cell_on_level.connect(_on_buy_free_cells)

	leaderboard_options["leaderboardName"] = Config.LEADERBOARD_NAME
	match Bridge.platform.id:
		"yandex":
			leaderboard_options = {
				"leaderboardName": Config.LEADERBOARD_NAME,
				"score": 0
			}


func _on_buy_free_cells(count: int) -> void:
	""" Удаляет случайные count блоков на карте """
	var _non_empty_cells = LevelManager.get_non_empty_cells(current_level)

	# исключаем рекламные блоки
	var _non_empty_cells_no_ads: Array
	for i in _non_empty_cells:
		if i.colors == LevelData.ADS_CELL:
			continue
		_non_empty_cells_no_ads.push_back(i)

	# перемешиваем найденные блоки
	_non_empty_cells_no_ads.shuffle()

	# удаляем случайные пять блоков на карте
	for i in _non_empty_cells_no_ads.slice(0, count):
		current_level[i.position.y][i.position.x] = LevelData.FREE_CELL
		var _cell_idx_in_grid = Utils.get_index_by_pos(i.position, current_level[0].size())
		var cell = block_container.get_child(_cell_idx_in_grid)
		var cb = cell.get_color_block()
		cb.remove_block()


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

	# увеличиваем на 1 так как current_level это индекс уровня
	leaderboard_options["score"] = LevelManager.current_level

	prints("next level", leaderboard_options, Bridge.player.is_authorized, Bridge.leaderboard.is_set_score_supported)

	#if Bridge.player.is_authorized and Bridge.leaderboard.is_set_score_supported:
	prints("set score")
	Bridge.leaderboard.set_score(leaderboard_options, Callable(self, "_on_set_score_completed"))

	_restart_level()


func _on_set_score_completed(value) -> void:
	prints("_on_set_score_completed", value)


func _make_colored_color_block(cb: Node) -> void:
	if pregenerated_color_blocks.size():
		var _colors = pregenerated_color_blocks.pop_front()
		cb.colors = _colors
		cb.update_tiles(_colors)
	else:
		var _colors = LevelManager.get_target_colors().keys()
		_colors.append_array(LevelManager.get_current_level_colors())
		var used_colors = Utils.uniq_array(_colors)
		cb.create_random_color(used_colors)


func run_tutorial() -> void:
	match LevelManager.current_level:
		0:
			prints("how to play totorial")
			var _pos1 = block_for_drop_1.global_position + block_center_offset
			var free_cell = LevelManager.get_free_cells(current_level)[0]
			var free_cell_node = block_container.get_child(Utils.get_index_by_pos(free_cell.position, 6))
			var _pos2 = free_cell_node.global_position + block_center_offset

			tutorial.run()
			tutorial.run_level_01(_pos1, _pos2)
		3:
			prints("hammer tutorial")
			if not Player.get_value("get_free_hammers"):
				Player.set_value("hammer", Player.get_value("hammer") + Config.DEMO_HAMMER_COUNT)
				Player.set_value("get_free_hammers", 1)
				Player.save_data()

			hammer_button.count = Player.get_value("hammer")
			var _pos = hammer_button.global_position + block_center_offset
			tutorial.run()
			tutorial.run_click_hammer(_pos + Vector2(-70, -70), _pos)
		5:
			prints("shuffle tutorial")
			if not Player.get_value("get_free_shuffles"):
				Player.set_value("shuffle", Player.get_value("shuffle") + Config.DEMO_SHUFFLE_COUNT)
				Player.set_value("get_free_shuffles", 1)
				Player.save_data()

			shuffle_button.count = Player.get_value("shuffle")
			var _pos = shuffle_button.global_position + block_center_offset
			tutorial.run()
			tutorial.run_click_hammer(_pos + Vector2(-70, -70), _pos)
		7:
			prints("bomb tutorial")
			if not Player.get_value("get_free_bombs"):
				Player.set_value("bomb", Player.get_value("bomb") + Config.DEMO_BOMB_COUNT)
				Player.set_value("get_free_bombs", 1)
				Player.save_data()
			bomb_button.count = Player.get_value("bomb")
			var _pos = bomb_button.global_position + block_center_offset
			tutorial.run()
			tutorial.run_click_hammer(_pos + Vector2(0, -70), _pos)


func _restart_level() -> void:
	BLOCK_ARR = []
	turns = 0

	for i in block_container.get_children():
		block_container.remove_child(i)

	# блокируем бустеры на ранних уровнях
	for booster_button in [hammer_button, bomb_button, shuffle_button]:
		var _b = booster_button.booster
		booster_button.set_locked(not _b.is_enabled_on_level(LevelManager.current_level))

	LevelManager.is_prev_gameover = false
	var goal_colors_value = LevelManager.get_target_colors()
	EventBus.goals_changed.emit(goal_colors_value)
	goal_colors_container.set_colors(goal_colors_value)

	create_level()
	BLOCK_ARR = block_container.get_children()

	_locks = LevelManager.get_block_with_lock(current_level)

	_make_colored_color_block(block_for_drop_1)

	# скрытие второго раздатчика блоков на первом и втором уровнях
	if Player.get_value("current_level") in [0, 1]:
		new_block_cell_right.hide()
	else:
		new_block_cell_right.show()
		_make_colored_color_block(block_for_drop_2)

	_update_ui()
	_set_state(EState.PLAY)

	# Обучение

	# задержка нужна что-бы позиции элементов успели синхронизироваться
	await Utils.timeout(0.2)
	run_tutorial()


func _process(delta: float) -> void:
	if Config.CHEATS_ENABLED:
		# Включение/Выключение показа номера цвета на цветном блоке
		if Input.is_action_just_pressed("DEBUG_KEY_1"):
			prints("DEBUG_KEY_1 just pressed")
			tutorial.stop()
			_debug_var_1 = not _debug_var_1
			block_for_drop_1._enable_debug_label(_debug_var_1)
			block_for_drop_2._enable_debug_label(_debug_var_1)

			for i in block_container.get_children():
				var _cb = i.get_color_block()
				if _cb != null:
					_cb._enable_debug_label(_debug_var_1)

		if Input.is_action_just_pressed("DEBUG_KEY_2"):
			prints("DEBUG_KEY_2 just pressed")
			prints("COINS +1000")
			tutorial.stop()
			EventBus.coins_changed.emit(Player.get_value("coins") + 1000)
			Player.save_data()

		if Input.is_action_just_pressed("DEBUG_KEY_3"):
			prints("DEBUG_KEY_3 just pressed")
			tutorial.stop()
			EventBus.level_complete.emit(Player.get_value("current_level") + 1)

		if Input.is_action_just_pressed("DEBUG_KEY_4"):
			prints("DEBUG_KEY_4 just pressed")
			prints("PREV LEVEL")
			if LevelManager.current_level > 0:
				LevelManager.current_level -= 1
				Player.set_value("current_level", LevelManager.current_level)
				Player.save_data()
				_restart_level()

			tutorial.stop()

		if Input.is_action_just_pressed("DEBUG_KEY_5"):
			prints("DEBUG_KEY_5 just pressed")
			tutorial.stop()

			prints("NEXT LEVEL")
			LevelManager.current_level += 1
			Player.set_value("current_level", LevelManager.current_level)
			Player.save_data()
			_restart_level()

		if Input.is_action_just_pressed("DEBUG_KEY_6"):
			prints("DEBUG_KEY_6 just pressed")
			tutorial.stop()

			#prints("GAME OVER")
			EventBus.game_over.emit()

			# Очистка данных игрока
			#for i in Player._data.keys():
				#if not i.begins_with("mute_"):
					#Player._data[i] = 0
			#Player.save_data()


func _input(event):
	var drop = false

	if event is InputEventMouseButton:

		# при клике останавливаем туториал
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tutorial.stop()

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			var count = 0
			for i in block_container.get_children():
				if i.select:
					SFX.play_sound("cube_install")
					# TODO: объединить повторяющийся код из IF
					if block_for_drop_1.follow_mouse:
						block_for_drop_1.drop_block()
						i.add_block()
						move_node(block_for_drop_1, i)
						var buff = color_block.instantiate()
						new_block_cell_left.add_child(buff)
						if Config.CHEATS_ENABLED:
							buff._enable_debug_label(_debug_var_1)
						_make_colored_color_block(buff)

						block_for_drop_1 = buff
						update_level()
						var _pos = Vector2i(count % 6, count / 6)
						turns += 1
						check_matches(_pos)
						drop = true

					elif block_for_drop_2.follow_mouse:
						block_for_drop_2.drop_block()
						i.add_block()
						move_node(block_for_drop_2, i)
						var buff = color_block.instantiate()
						new_block_cell_right.add_child(buff)
						_make_colored_color_block(buff)
						block_for_drop_2 = buff
						update_level()
						var _pos = Vector2i(count % 6, count / 6)
						turns += 1
						check_matches(_pos)
						drop = true
						if Config.CHEATS_ENABLED:
							buff._enable_debug_label(_debug_var_1)

					break
				count += 1

			if drop == false:
				block_for_drop_1.button_up()
				block_for_drop_1.position = Vector2(-35, -32)
				block_for_drop_2.button_up()
				block_for_drop_2.position = Vector2(-35, -32)

				# TODO: определять что блок не просто отпущен, а вернулся потому что сброшен в непустую клетку
				#SFX.play_sound("cube_noneinstall")


func _update_ui() -> void:
	level_title.level_value = LevelManager.current_level + 1

	var _dif = "normal"

	if LevelManager.is_current_level_hard():
		_dif = "hard"
	elif LevelManager.is_current_level_super_hard():
		_dif = "super_hard"

	level_title.difficulty = _dif


func move_node(block: Node, new_parent: Node):
	var old_parent = block.get_parent()
	old_parent.remove_child(block)
	block.pressed.connect(_on_color_block_pressed)
	new_parent.add_child(block)
	block.z_index = 0
	block.position = Vector2(-50, -50)


func _make_all_color_blocks_button() -> void:
	for i in block_container.get_children():
		if i.active and not i.can_drop_block:
			var color_block = i.get_child(-1)
			color_block.set_is_button(true)


func _demake_all_color_blocks_button() -> void:
	for i in block_container.get_children():
		if i.active and not i.can_drop_block:
			var node = i.get_color_block()
			if node is ColorBlock2D:
				node.set_is_button(false)


func _on_ads_cell_pressed(cell: Cell2D) -> void:
	_current_cell_rewarded = cell
	if _state == EState.PLAY:
		Bridge.advertisement.show_rewarded()


func _on_rewarded_state_changed(status: String) -> void:
	if status == "rewarded":
		if _current_cell_rewarded != null:
			_current_cell_rewarded.cell_type = "normal"
			var pos = _current_cell_rewarded.level_position
			current_level[pos.y][pos.x] = LevelData.FREE_CELL
			_current_cell_rewarded = null


func create_level() -> void:
	current_level = LevelManager.get_current_level()
	pregenerated_color_blocks = LevelManager.get_pregenerated_color_blocks()

	# удаляем старые клетки
	for i in block_container.get_children():
		block_container.remove_child(i)

	# ищем и записываем все живые кубы на поле
	live_block_list = []
	var cb_level = LevelManager.create_color_blocks(current_level)

	for i in cb_level:
		if i.is_live():
			live_block_list.push_back(i)

	for i in range(current_level.size()):
		for j in range(current_level[i].size()):
			var buff = cell_block.instantiate()
			buff.level_position.x = j
			buff.level_position.y = i

			var current_level_cell = current_level[i][j]

			if current_level_cell == LevelData.ADS_CELL:
				block_container.add_child(buff)
				buff.cell_type = "ads"
				buff.show_ads.connect(_on_ads_cell_pressed.bind(buff))

			elif current_level_cell != LevelData.EMPTY_CELL:
				block_container.add_child(buff)

				if current_level_cell != LevelData.FREE_CELL:
					var _cb = color_block.instantiate()
					buff.add_child(_cb)
					_cb.pressed.connect(_on_color_block_pressed)
					buff.not_can_drop()
					_cb.colors = current_level_cell
					_cb.update_tiles(current_level_cell)

			elif current_level_cell == LevelData.EMPTY_CELL:
				block_container.add_child(buff)
				buff.set_active(false)

	block_container.anchors_preset = Control.PRESET_FULL_RECT
	block_container.anchors_preset = Control.PRESET_CENTER

	update_level()


func _on_color_block_pressed(block: Node) -> void:
	# работает только во время использования бустера

	if _state == EState.BOOSTER:
		if current_booster.type == Booster.EType.HAMMER:
			hammer(block)
			_set_state(EState.PLAY)
			EventBus.booster_used.emit(current_booster.type)
		elif current_booster.type == Booster.EType.BOMB:
			var cell_pos = block.get_parent().level_position

			# запустить анимацию падения бомбы _здесь_
			animation_bomb.position = block.global_position + Vector2(50, 50)
			animation_bomb.play()

			# Ждём когда пройдёт анимация падения бомбы
			await Utils.timeout(1.25)

			# удаляем указанный блок
			var _colors = block.colors
			block.colors = LevelData.FREE_CELL
			block.remove_block()

			for tile_color in Utils.uniq_array(_colors):
				goal_colors_container.dec_color(tile_color, 1)

			# запускаем удаление плиток соседей
			await bomb_explode_neighbours(cell_pos, animation_bomb.position)
			_set_state(EState.PLAY)
			EventBus.booster_used.emit(current_booster.type)


func hammer(block: Node) -> void:
	var _colors = block.colors.duplicate(true)
	block.colors = LevelData.FREE_CELL
	var animation = hammer_animation

	# выравниваем анимацию по центру блока
	animation.position = block.global_position + Vector2(50, 50)

	animation.z_index = 100
	animation.play()

	# ждём анимацию
	var animation_time: float = 2.2
	var time_to_remove_block: float = 1.7

	# ждём момент удара
	await Utils.timeout(time_to_remove_block)
	# удаляем блок
	block.remove_block()

	for tile_color in Utils.uniq_array(_colors):
		goal_colors_container.dec_color(tile_color, 1)

	update_level()


func bomb_explode_neighbours(pos: Vector2i, global_pos: Vector2) -> void:
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

	await Utils.timeout(0.3)
	var _bomb_parts: Array

	var _target_blocks: Array

	for side in neighbours:
		var n_pos = side + pos

		if n_pos.x >= 0 and n_pos.x < level_width - 1 and n_pos.y >= 0 and n_pos.y < level_height - 1:
			var cur_level_cell = current_level[n_pos.y][n_pos.x]
			if cur_level_cell == LevelData.EMPTY_CELL:
				continue

			var _cell = get_cell_by_pos(n_pos)
			var _block = _cell.get_color_block()

			if _block != null:
				var _rnd_index = randi_range(0, 3)
				var _color = _block.colors[_rnd_index]
				goal_colors_container.dec_color(_color, 1)
				var _remove_color = cur_level_cell[_rnd_index]

				var sides = {
					0: ColorBlock.ESides.TOP,
					1: ColorBlock.ESides.RIGHT,
					2: ColorBlock.ESides.BOTTOM,
					3: ColorBlock.ESides.LEFT,
				}
				var _cb = LevelManager.get_color_block(n_pos, current_level)

				_target_blocks.push_back({
					"cb": _cb,
					"remove_color": _remove_color,
					"side": sides[_rnd_index],
					"block": _block,
				})

	# Анимация осколка
	for i in _target_blocks:
		var _block = i["block"]
		var _bomb_part = load("res://Scenes/BoosterUi/bomb_part.tscn").instantiate()
		_bomb_part.position = global_pos
		_bomb_part.z_index = 100
		add_child(_bomb_part)
		_bomb_parts.push_back(_bomb_part)
		var _target_pos = _block.global_position + Vector2(50, 50)
		Utils.jump_to_position(_bomb_part, _target_pos, 0.3)

	# ждём когда осколки долетят
	await Utils.timeout(0.31)

	# удаляем осколки
	for i in _bomb_parts:
		remove_child(i)

	# удаляем цвета на блоках, на которые упали осколки
	for i in _target_blocks:
		var _cb = i["cb"]
		if _cb.has_lock():
			continue
		var _remove_color = i["remove_color"]
		var side = i["side"]
		var _block = i["block"]
		_cb_node_remove_colors(_cb, _remove_color, side)
		var _side = side
		# костыль - в некоторых кейсах, цвет не удаляется
		match side:
			0:
				_side = 2
			1:
				_side = 3
			2:
				_side = 0
			3:
				_side = 1
		_cb_node_remove_colors(_cb, _remove_color, _side)

		_block.colors = _cb.colors

	await Utils.timeout(0.2)
	for i in _target_blocks:
		check_matches(i["cb"].position)


func shuffle() -> void:
	var _non_empty_cells = LevelManager.get_non_empty_cells(current_level)
	var _non_empty_without_lock: Array

	# убираем блоки с замком
	for i in _non_empty_cells:
		var cb = ColorBlock.new()
		cb.colors = i.colors
		if cb.has_lock():
			continue
		else:
			_non_empty_without_lock.push_back(i)

	_non_empty_cells = _non_empty_without_lock

	var _new_non_empty_cells = _non_empty_cells.duplicate(true)
	_new_non_empty_cells.shuffle()

	await Utils.timeout(0.5)
	SFX.play_sound("spinner")

	const UP_DURATION = 0.2
	const MOVE_DURATION = 0.5
	const DOWN_DURATION = 0.3

	var _animated_blocks: Array

	# для каждого блока создаём копию для анимации. Скрываем сам блок
	for i in _non_empty_cells.size():
		var _cell = _non_empty_cells[i]
		var _new_cell = _new_non_empty_cells[i]

		prints("move", _cell, "to", _new_cell)
		var _tween = create_tween()

		var cell_block = get_cell_by_pos(_cell.position)
		var color_block_node = cell_block.get_color_block()
		var new_cell_block = get_cell_by_pos(_new_cell.position)
		var new_color_block_node = new_cell_block.get_color_block()

		# создаём копию цветного блока для перемещения
		var cb = load("res://Scenes/ColorBlock/color_block2d.tscn").instantiate()
		add_child(cb)
		cb.update_tiles(color_block_node.colors)
		cb.position = color_block_node.global_position - Vector2(50, 50)

		color_block_node.hide()
		new_color_block_node.hide()

		# подъём над ячейкой
		var _up_pos = color_block_node.global_position.y - 100

		_tween.tween_property(cb, "position:y", _up_pos, UP_DURATION)
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.chain()

		# Перемещение на новую позицию (будет находиться выше ячейки из-за подъёма)
		var _new_pos = new_color_block_node.global_position - Vector2(50, 50) - Vector2(0, 100)

		_tween.tween_property(cb, "position", _new_pos, MOVE_DURATION)
		_tween.set_ease(Tween.EASE_IN_OUT)

		# опускание на ячейку
		_tween.tween_property(cb, "position", _new_pos + Vector2(0, 100), DOWN_DURATION)
		_tween.play()
		_animated_blocks.push_back(cb)
		#_tween.tween_callback(_restore_color_block.bind(cb, color_block_node))

	await Utils.timeout(UP_DURATION + MOVE_DURATION + DOWN_DURATION + 0.01)

	# удаляем летающие блоки после анимации
	for i in _animated_blocks:
		remove_child(i)

	# назначаем новые цвета блокам
	for i in _non_empty_cells.size():
		var _cb = _non_empty_cells[i]
		var _new_cb = _new_non_empty_cells[i]

		if _cb.is_live():
			# перемещаем живой блок в новую позицию
			for j in live_block_list:
				if j.position == _cb.position:
					j.position = _new_cb.position

		var cell_block = get_cell_by_pos(_cb.position)
		var color_block_node = cell_block.get_color_block()
		var new_cell_block = get_cell_by_pos(_new_cb.position)
		var new_color_block_node = new_cell_block.get_color_block()

		new_color_block_node.colors = _cb.colors
		new_color_block_node.update_tiles(_cb.colors)
		new_color_block_node.show()
		current_level[_new_cb.position.y][_new_cb.position.x] = _cb.colors

	for cell in _new_non_empty_cells:
		check_matches(cell.position)


func _restore_color_block(moving_cb_node, cb) -> void:
	remove_child(moving_cb_node)
	if is_instance_valid(cb):
		cb.show()


func update_level() -> void:
	# Обновляет данные текущего уровня из блоков на игровом поле

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

	block_container.anchors_preset = Control.PRESET_FULL_RECT
	block_container.anchors_preset = Control.PRESET_CENTER


# TODO: подумать над переносом в ColorBlock
func _is_match_side_color(tile_color: int, current_block: ColorBlock, neighbour_block: ColorBlock, current_side: ColorBlock.ESides, neighbour_side: ColorBlock.ESides) -> bool:
	var _DEBUG = false

	var n_side_tiles = neighbour_block.get_side_color_tiles(neighbour_side)

	for i in n_side_tiles:
		if i.color == tile_color and i.is_lock():
			return false

	var tile_color_in_neighbour = tile_color in neighbour_block.get_side_colors(neighbour_side)
	var is_neighbour_colors_equal = neighbour_block.is_side_colors_equal(neighbour_side)
	var is_block_colors_equal = current_block.is_side_colors_equal(current_side)

	if is_block_colors_equal\
	 and is_neighbour_colors_equal\
	 and tile_color_in_neighbour:
		if _DEBUG:
			prints("1) вся сторона текущего блока одного цвета и совпадает с всей стороной соседа")
		return true

	elif current_block.is_side_colors_equal(current_side) and tile_color_in_neighbour:
		if _DEBUG:
			prints("2) вся сторона текущего блока одного цвета, этот цвет есть в соседнем блоке")
		return true

	elif neighbour_block.is_side_colors_equal(neighbour_side) and tile_color_in_neighbour:
		if _DEBUG:
			prints("3) вся сторона соседа одного цвета, этот цвет есть в текущем блоке")
		return true

	else:
		var cur_side_colors = current_block.get_side_colors(current_side)
		var nei_side_colors = neighbour_block.get_side_colors(neighbour_side)

		# на сторонах блоков нет нужного цвета
		if tile_color not in cur_side_colors or tile_color not in nei_side_colors:
			return false

		var cur_color_index = cur_side_colors.find(tile_color)
		var nei_color_index = nei_side_colors.find(tile_color)

		if cur_color_index == nei_color_index:
			if _DEBUG:
				prints("4) у соседа есть цвет на той-же позиции что у текущего блока")
			return true

	return false


func _cb_node_remove_colors(color_block: ColorBlock, color: int, side: ColorBlock.ESides) -> Node:
	""" анимированно удаляем цвет у ColorBlock ноды """
	var result: Node

	var cur_fill_dir = color_block.remove_color(color, side)
	var block_node = get_color_block(color_block.position)

	if block_node == null:
		return

	if color_block.is_iced():
		color_block.normalize_colors()
		block_node.colors = color_block.colors
		block_node.update_tiles(color_block.colors)
		return

	# получаем удаляемый тайл
	result = block_node.get_color_tile_node(color)

	block_node.colors = color_block.colors
	# анимируем заполнение дыр в блоке
	block_node.fill_colors(cur_fill_dir)
	color_block.autofill(side)

	# обновляем ячейку уровня
	current_level[color_block.position.y][color_block.position.x] = color_block.colors

	return result


func get_cell_by_pos(pos: Vector2i) -> Cell2D:
	var cell = block_container.get_child(Utils.get_index_by_pos(pos, 6))
	return cell


func check_matches(pos: Vector2i) -> void:
	""" Рекурсивно проверяет все блоки вокруг на совпадения цветов """

	_set_state(EState.CHECK)
	# счётчик запуска функции
	check_match_count += 1
	var time_before_check_next: float = 0.7

	# За границами поля
	if not _in_level_field(pos):
		return

	var current_block = LevelManager.get_color_block(pos, current_level)

	if current_block.is_iced():
		check_match_count -= 1
		return

	var around_blocks: Array
	var tile_index: int
	var tile_color: int

	# блоки у которых совпадают цвета с current_block
	var matched_blocks: Array

	# ищем любые блоки прилегающие к цвету текущего блока
	if current_block.get_unique_colors().size() == 1:
		tile_index = 0
		tile_color = current_block.colors[tile_index]
		# цвет у блока один, значит берём все существующие блоки вкруг
		around_blocks = get_blocks_around_tile(current_block, tile_index)
		for j in around_blocks:
			if _is_match_side_color(tile_color, current_block, j.block, j.current_side, j.neighbour_side):
				matched_blocks.push_back(j)

	else:
		# у текущего блока больше одного цвета

		# Обходим тайлы текущего блока
		var tile_list = [0, 1, 2, 3]

		for i in tile_list:
			tile_index = i
			tile_color = current_block.colors[tile_index]
			around_blocks = get_blocks_around_tile(current_block, tile_index)
			# ищем совпадения по блокам вокруг

			for j in around_blocks:
				if _is_match_side_color(tile_color, current_block, j.block, j.current_side, j.neighbour_side):
					matched_blocks.push_back(j)

			# если найден хоть один блок, прилегающий к тайлу
			if matched_blocks.size():
				#prints("найден блок с совпадающим цветом")
				break

	if matched_blocks.size() > 0:
		#prints("анимация удаления тайла:", tile_color, LevelData.COLOR_NAMES[tile_color])

		# Засчитываем цель по цвету
		goal_colors_container.dec_color(tile_color, 1)
		# Оповещаем всех что цель обновилась
		EventBus.goals_changed.emit(goal_colors_container.colors)

		var tiles_to_remove: Array
		var _tile = _cb_node_remove_colors(current_block, tile_color, matched_blocks[0].current_side)
		if _tile:
			tiles_to_remove.push_back(_tile)

		for i in matched_blocks:
			if i.block.is_iced():
				# Размораживаем блок, но не мержим
				var _cell = get_cell_by_pos(i.block.position)
				var _block = _cell.get_color_block()
				i.block.normalize_colors()
				_block.colors = i.block.colors
				_block.update_tiles(_block.colors)
				_block.ice_node.visible = false
				# ...не мержим
				continue

			goal_colors_container.dec_color(tile_color, 1)
			EventBus.goals_changed.emit(goal_colors_container.colors)

			# Проверяем что удалился ключ
			var _color_tile = i.block.get_color_tile(tile_color)
			if _color_tile.is_key():
				var block_node = get_color_block(i.block.position)
				_key_retrieved(_color_tile, block_node)

			var _tile2 = _cb_node_remove_colors(i.block, tile_color, i.neighbour_side)
			tiles_to_remove.push_back(_tile2)

		var used_block_list = [{"block": current_block}]
		used_block_list.append_array(matched_blocks)

		# --- Анимируем все удаляемые цветные тайлы ---
		# ищем среднюю точку между всех тайлов
		var _tiles_positions: Array[Vector2]
		for i in tiles_to_remove:
			if i == null:
				continue

			var _pos = i.position
			_tiles_positions.push_back(_pos)

		var center_pos = Utils.find_center_of_position_list(_tiles_positions)

		var _tween_time: float = 1

		for t in tiles_to_remove:
			if t == null:
				continue

			var _tween = create_tween().set_parallel()
			add_child(t)
			t.z_index = 100

			# поднимаем блок вверх
			# масштаб у ColorBlock 0.5, если не сделать такой-же масштаб тайлу - он будет большой
			t.scale = Vector2(0.5, 0.5)

			# Поднимает блок вверх
			var _up_tween_time = 0.3
			_tween.tween_property(t, "scale", t.scale + Vector2(0.1, 0.1), _up_tween_time)
			_tween.tween_property(t, "position", t.position + Vector2(0, -55), _up_tween_time)
			_tween.set_ease(Tween.EASE_OUT)
			_tween.chain()

			_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

			# корректировка координаты центра
			var _correct_center_pos = center_pos #+ Vector2(-(t.size.x / 4), -(t.size.y / 2))
			var _center_tween_time = 0.65
			_tween.tween_property(t, "position", _correct_center_pos, _center_tween_time)
			_tween.tween_property(t, "scale", Vector2(0, 0), _center_tween_time)
			_tween.tween_property(t, "modulate", Color(1,1,1,0), 0.5)
			_tween.chain()
			_tween.tween_property(t, "modulate", Color(1,1,1,0), _center_tween_time)
			_tween.play()
			_tween.tween_callback(remove_child.bind(t))
			SFX.play_sound("cube_merge")

		#await Utils.timeout(0.1)

		# --- запускаем проверку для всех изменённых блоков ---
		for i in used_block_list:
			var cb = i.block
			await Utils.timeout(time_before_check_next * 0.7)
			check_matches(cb.position)

	check_match_count -= 1

	if check_match_count < 1:
		await Utils.timeout(0.2)
		_set_state(EState.PLAY)
		update_level()
		check_level_complete()
		check_game_over()
		move_live_block()


func get_color_block(pos: Vector2i) -> ColorBlock2D:
	var _cell = get_cell_by_pos(pos)
	var _block: ColorBlock2D = _cell.get_color_block()
	return _block


func move_live_block() -> void:
	var _cleanup: Array[ColorBlock] = []

	for i in live_block_list.size():
		var lb = live_block_list[i]
		var cell = block_container.get_child(Utils.get_index_by_pos(lb.position, 6))

		if cell.get_color_block() is ColorBlock2D:
			_cleanup.push_back(lb)

	live_block_list = _cleanup

	if turns > _prev_turn:
		_prev_turn = turns
		for lb in live_block_list:
			var free_cells_around: Array
			for i in LevelManager.get_around_cells(current_level, lb.position):
				var _cell_data = current_level[i.y][i.x]
				if _cell_data == LevelData.FREE_CELL:
					var _cb = ColorBlock.new()
					_cb.colors = _cell_data
					_cb.position = i
					free_cells_around.push_back(_cb)

			var not_merge_cells := []
			for i in free_cells_around:
				# проверяем мержится ли в ячейке текущий живой блок
				var tile_list = [0, 1, 2, 3]

				var is_merge_place: bool = false

				for j in tile_list:
					var tile_index = j
					var current_block = ColorBlock.new()
					current_block.colors = lb.colors
					current_block.position = i.position
					var tile_color = current_block._color_tiles[tile_index].color
					var around_blocks = get_blocks_around_tile(current_block, tile_index)
					# ищем совпадения по блокам вокруг

					for k in around_blocks:
						var k_pos = k.block.position
						if k_pos.x == lb.position.x and k_pos.y == lb.position.y:
							break

						if _is_match_side_color(tile_color, current_block, k.block, k.current_side, k.neighbour_side):
							is_merge_place = true
							break

					if is_merge_place:
						break

				if not is_merge_place:
					not_merge_cells.push_back(i)

			free_cells_around = not_merge_cells

			if not free_cells_around.size():
				return

			var random_free_cell = free_cells_around.pick_random()

			if random_free_cell:
				current_level[random_free_cell.position.y][random_free_cell.position.x] = lb.colors
				current_level[lb.position.y][lb.position.x] = LevelData.FREE_CELL
				var _old_cell = block_container.get_child(Utils.get_index_by_pos(lb.position, 6))
				var _new_cell = block_container.get_child(Utils.get_index_by_pos(random_free_cell.position, 6))

				var _old_block = _old_cell.get_color_block()

				# Перемещаем блок из одной ячейки в другую
				_old_cell.remove_child(_old_block)

				# добавляем блок на основную сцену для анимации прыжка
				add_child(_old_block)
				_old_block.position = _old_cell.global_position + Vector2(-50, -50)
				const JUMP_DURATION = 0.3
				Utils.jump_to_position(_old_block, _new_cell.global_position + Vector2(-50, -50), JUMP_DURATION)
				await Utils.timeout(JUMP_DURATION)
				# прыжок закончен, можно удалять из основной сцены
				remove_child(_old_block)

				# после прыжка добавляем в новую ячейку
				_new_cell.add_child(_old_block)
				_new_cell.not_can_drop()
				_old_block.position = Vector2(-50, -50)
				_old_cell.free_block()

				lb.position = random_free_cell.position
				update_level()


func _in_level_field(pos: Vector2i) -> bool:
	# За границами поля
	if pos.x < 0 or pos.x >= current_level[0].size() or pos.y < 0 or pos.y >= current_level.size():
		return false

	return true


func get_blocks_around_tile(color_block: ColorBlock, tile_index) -> Array:
	""" Возвращает блоки, прилегающие к указанному тайлу текущего блока """

	var result: Array

	var tile_side_list = color_block._tile_sides(tile_index)

	for side in tile_side_list:
		var neighbour_pos = color_block._side_position(side)
		if not _in_level_field(neighbour_pos):
			continue

		var neighbour_block = LevelManager.get_color_block(neighbour_pos, current_level)

		# данные о соседнем блоке
		var data = {
			# соседний блок
			"block": LevelManager.get_color_block(neighbour_pos, current_level),
			# сторона с которой соседний блок прилегает к color_block
			"current_side": side,
			# сторона с которой color_block прилегает к соседу
			"neighbour_side": ColorBlock.REVERSE_SIDE[side]
		}

		# отсекаем пустые и неиспользуемые ячейки
		if neighbour_block.is_free() or neighbour_block.colors == LevelData.EMPTY_CELL:
			#prints("is empty or free block")
			continue

		result.push_back(data)

	return result


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
		EventBus.level_complete.emit(LevelManager.current_level)


func _set_booster_ui() -> void:
	booster_ui.booster = current_booster
	booster_ui._update_ui()


func _on_booster_button_pressed(booster: Booster) -> void:
	if _state != EState.PLAY:
		return

	current_booster = booster
	var booster_count = Player.get_booster_count(booster.type)
	if booster_count == 0:
		EventBus.buy_booster.emit(booster)
	else:
		_set_state(EState.BOOSTER)
		tutorial.hide_pointer()
		if LevelManager.current_level not in [3, 5]:
			return

		if current_booster.type == Booster.EType.HAMMER:
			var cell = block_container.get_child(Utils.get_index_by_pos(Vector2i(3, 3), 6))
			var pos = cell.global_position + block_center_offset
			prints("hammer second tutorial")
			tutorial.stop()
			tutorial.run()
			tutorial.run_click_hammer(pos + Vector2(80, 80), pos)
		if current_booster.type == Booster.EType.BOMB:
			var cell = block_container.get_child(Utils.get_index_by_pos(Vector2i(3, 3), 6))
			var pos = cell.global_position + block_center_offset
			prints("bomb second tutorial")
			tutorial.stop()
			tutorial.run()
			tutorial.run_click_hammer(pos + Vector2(80, 80), pos)


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
	_set_state(EState.PLAY)


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


func _key_retrieved(_color_tile, cb) -> void:
	var lock_type = ColorTile.get_lock_type(_color_tile.type)

	var key_pos = cb.global_position

	var _filtered_locks: Array
	for i in _locks:
		for j in i._color_tiles:
			if j.type == lock_type:
				_filtered_locks.push_back(i)
				break

	for i in _filtered_locks:
		i.remove_lock(_color_tile.color, lock_type)
		var lock_pos = get_color_block(i.position).global_position

		var key_node = load("res://Scenes/Key/key.tscn").instantiate()
		add_child(key_node)
		key_node.z_index = 130
		key_node.position = key_pos + Vector2(25, 70) # корректировка позиции
		key_node.type = _color_tile.type
		key_node.scale = Vector2(1, 1)

		SFX.play_sound("key_1")
		Utils.jump_to_position(key_node, lock_pos + Vector2(100, 100), 0.7)
		await Utils.timeout(0.65)
		SFX.play_sound("key_2")

		remove_child(key_node)

		current_level[i.position.y][i.position.x] = i.colors
		var cell_idx = Utils.get_index_by_pos(i.position, 6)
		var color_block2d = block_container.get_child(cell_idx).get_color_block()
		color_block2d.colors = i.colors
		color_block2d.update_tiles(i.colors)
		check_matches(i.position)
