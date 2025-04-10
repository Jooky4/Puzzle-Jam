extends Node2D

@onready var EMPTY_BLOCK = preload("res://Scenes/Block/empty_block.tscn")
@onready var COLOR_BLOCK = preload("res://Scenes/Block/block.tscn")
@onready var block_container = $UI/GridContainer

@onready var block_for_drop_1 = $UI/VBoxContainer/ColorRect/Block
@onready var block_for_drop_2 = $UI/VBoxContainer/ColorRect2/Block2

func _ready() -> void:
	create_level()

func _input(event):
	var drop = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
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
						drop = true
					elif block_for_drop_2.follow_mouse:
						block_for_drop_2.drop_block()
						i.add_block()
						move_node(block_for_drop_2, i)
						var buff = COLOR_BLOCK.instantiate()
						$UI/VBoxContainer/ColorRect2.add_child(buff)
						buff.create_random_color()
						block_for_drop_2 = buff
						drop = true
					break

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
	var level_arr = LevelManager.get_current_level_setup()

	for i in range(level_arr.size()):
		for j in range(level_arr[i].size()):
			var buff = EMPTY_BLOCK.instantiate()
			if level_arr[i][j] != [-1, -1, -1, -1]:
				block_container.add_child(buff)
	
				if level_arr[i][j] != [0, 0, 0, 0]:
					var buff1 = COLOR_BLOCK.instantiate()
					buff.not_can_drop()
					buff.add_child(buff1)
					buff1.get_color_block(level_arr[i][j])

			elif level_arr[i][j] == [-1, -1, -1, -1]:
				buff.set_not_active()
				block_container.add_child(buff)

	block_container.anchors_preset = Control.PRESET_CENTER
