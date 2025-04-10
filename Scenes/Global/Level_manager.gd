extends Node

var CURRENT_LVL = 1

var COLOR_BLOCK = {
	11: Color.GREEN,
	12: Color.SKY_BLUE,
	13: Color.BLUE,
	14: Color.YELLOW,
	15: Color.PINK,
	16: Color.PURPLE,
	17: Color.RED,
	18: Color.BROWN
}

var LVL_1_COLOR = [[[3, 3, 3, 3], null, [3, 3, 3, 3]],
				   [[6, 6, 6, 6], [1, 1, 1, 1], [6, 6, 6, 6]],
				   [[5, 5, 5, 5], [6, 6, 6, 6], [4, 4, 4, 4]]]

var LVL_3_COLOR = [[null, null, null, null, null],
				   [null, null, [3, 6, 1, 6], [3, 5, 1, 5], null],
				   [null, [6, 4, 6, 3], [3, 3, 6, 1], null, [5, 1, 4, 4]],
				   [null, [5, 1, 6, 6], null, null, null],
				   [null, null, null, null, null]]

var LVL_24 = [[[-1, -1, -1, -1], [-1, -1, -1, -1], [14, 11, 14, 11], [13, 13, 13, 13], [14, 11, 14, 11], [-1, -1, -1, -1]],
			  [[-1, -1, -1, -1], [0, 0, 0, 0], [15, 15, 16, 16], [11, 15, 14, 16], [0, 0, 0, 0], [14, 13, 16, 15]],
			  [[-1, -1, -1, -1], [0, 0, 0, 0], [14, 14, 14, 14], [13, 13, 11, 11], [0, 0, 0, 0], [15, 13, 11, 11]],
			  [[-1, -1, -1, -1], [0, 0, 0, 0], [15, 16, 15, 16], [15, 15, 13, 13], [0, 0, 0, 0], [15, 15, 13, 13]],
			  [[-1, -1, -1, -1], [16, 15, 16, 15], [0, 0, 0, 0], [14, 15, 14, 15], [0, 0, 0, 0], [15, 14, 16, 16]],
			  [[-1, -1, -1, -1], [-1, -1, -1, -1], [13, 13, 15, 15], [16, 14, 16, 14], [11, 11, 16, 13], [-1, -1, -1, -1]]]

func get_random_color():
	var keys = COLOR_BLOCK.keys()
	var random_index = randi() % keys.size()
	var random_key = keys[random_index]
	return COLOR_BLOCK[random_key]

func get_current_level_setup() -> Array:
	return LVL_24
