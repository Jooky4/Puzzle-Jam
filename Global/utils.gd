extends Node

func timeout(value: float) -> void:
	await get_tree().create_timer(value).timeout


func uniq_array(arr: Array) -> Array:
	var _arr = arr.duplicate(true)
	var _dic: Dictionary

	for i in _arr:
		_dic[i] = true

	return _dic.keys()


func format_number(n: int) -> String:
	var result: String

	if n >= 1_000_000:
		result = str(float(n) / 1_000_000).replace(",", ".") + "KK"
	elif n >= 1_000:
		result = ("%.1f" % (float(n) / 1_000)).replace(".0", "") + "K"
	else:
		result = str(n)

	return result


func get_index_by_pos(pos: Vector2i, row_size: int) -> int:
	return pos.y * row_size + pos.x


func find_center_of_position_list(list: Array) -> Vector2:
	if list.is_empty():
		return Vector2.ZERO

	var sum = Vector2.ZERO
	for _pos in list:
		sum += _pos

	return sum / list.size()


func jump_to_position(node, target_position: Vector2, duration: float = 0.5, jump_height: float = 100.0):
	var start_pos = node.position
	var total_time = duration

	# Создаем кривую Безье для анимации прыжка (Y-смещение)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 3.6)

	# Пик дуги по центру
	curve.add_point(Vector2(0.5, 1))

	# подгибаем последнюю точку что-бы было падение а не планирование
	curve.add_point(Vector2(1, 0), -4.7)

	# Создаем tween
	var tween = get_tree().create_tween()
	tween.tween_callback(Callable(func():
		var elapsed = 0.0
		while elapsed < total_time:
			var t = elapsed / total_time
			var offset_y = curve.sample(t) * jump_height
			var current_pos = start_pos.lerp(target_position, t)
			current_pos.y -= offset_y
			node.position = current_pos
			await get_tree().process_frame
			elapsed += get_physics_process_delta_time()
	))
	tween.play()


func copy_file(source_path: String, dest_path: String) -> bool:
	# Проверяем, существует ли исходный файл
	if not FileAccess.file_exists(source_path):
		printerr("Файл не найден:", source_path)
		return false

	# Создаём папку назначения, если её нет
	var dest_dir = dest_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dest_dir):
		DirAccess.make_dir_recursive_absolute(dest_dir)

	# Копируем файл
	var error = DirAccess.copy_absolute(source_path, dest_path)
	if error != OK:
		printerr("Ошибка копирования (код ", error, "):", source_path, "->", dest_path)
		return false

	return true
