extends Node

#var COLOR_BLOCK = {
var COLORS = {
	10: Color.SKY_BLUE,
	11: Color.PURPLE,
	12: Color.BLUE,
	13: Color.GREEN,
	14: Color.YELLOW,
	15: Color.CRIMSON, # красный
	16: Color.PINK,
	17: Color("#4D220E"), # коричневый
}

# пустая, в неё ничего не положить
const EMPTY_CELL = [-1, -1, -1, -1]
# свободная ячейка, можно положить тайл
const FREE_CELL = [0, 0, 0, 0]
const ADS_CELL = [2, 2, 2, 2]

var target_by_level = [
	{ # Level 1
		10: 2,
		13: 2,
		11: 4,
		16: 2,
		14: 2,
	},
	{ # Level 2
		13: 5,
		10: 4,
		16: 5,
	},
	{ # level 3
		13: 8,
		10: 6,
	},
	{ # level 4
		16: 9,
		10: 8,
		13: 9,
	},
	{ # level 5
		11: 6,
		14: 8,
		13: 6
	},
	{ # level 6
		11: 6,
		14: 8,
		13: 6
	},
	{ # level 7
		13: 6,
		10: 7,
		11: 7,
	}
]

var levels = [
	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [10, 10, 10, 10], FREE_CELL, [10, 10, 10, 10]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [11, 11, 11, 11], [13, 13, 13, 13], [11, 11, 11, 11]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [16, 16, 16, 16], [11, 11, 11, 11], [14, 14, 14, 14]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, [11, 16, 11, 16], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [13, 10, 13, 10], [13, 13, 13, 13], [14, 14, 14, 14]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [16, 16, 16, 16], [11, 11, 11, 11], [16, 16, 10, 10]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, [10, 11, 13, 11], [10, 16, 13, 16], EMPTY_CELL],
	[EMPTY_CELL, FREE_CELL, [11, 14, 11, 10], [10, 10, 11, 13], FREE_CELL, [16, 14, 13, 14]],
	[EMPTY_CELL, EMPTY_CELL, [16, 13, 11, 11], FREE_CELL, FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, [10, 13, 16, 13], [11, 11, 11, 11], [16, 13, 10, 13], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, [11, 11, 11, 11], [14, 14, 14, 14], [11, 14, 11, 14], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, [13, 13, 13, 13], FREE_CELL, FREE_CELL, [14, 14, 16, 13]],
	[EMPTY_CELL, EMPTY_CELL, [10, 10, 10, 10], [16, 13, 11, 13], [11, 16, 14, 16], [10, 10, 11, 11]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [16, 12, 14, 12], [10, 15, 10, 15], [11, 14, 13, 10], [12, 13, 12, 10], [16, 15, 11, 13]],
	[EMPTY_CELL, [13, 11, 15, 14], [12, 12, 12, 12], [15, 15, 16, 16], [10, 14, 12, 15], [16, 12, 16, 12]],
	[EMPTY_CELL, [14, 12, 14, 12], FREE_CELL, [10, 15, 10, 15], [14, 14, 14, 14], [11, 14, 13, 13]],
	[EMPTY_CELL, [12, 11, 16, 11], [13, 14, 10, 16], [11, 11, 11, 11], FREE_CELL, [15, 15, 15, 15]],
	[EMPTY_CELL, [15, 13, 11, 13], [11, 11, 11, 11], [15, 14, 15, 14], [12, 12, 12, 12], [10, 10, 10, 10]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [11, 14, 10, 16], [13, 16, 11, 10], [14, 11, 13, 16], [16, 14, 13, 14], EMPTY_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [10, 11, 10, 14], [14, 16, 10, 10], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, [16, 10, 13, 10], [16, 13, 11, 14], [14, 11, 16, 13]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [15, 10, 16, 16], EMPTY_CELL, [10, 13, 10, 13], EMPTY_CELL, [16, 16, 14, 14]],
	[EMPTY_CELL, [11, 11, 15, 15], [14, 15, 16, 11], [12, 14, 16, 15], [12, 16, 10, 16], [15, 12, 15, 12]],
	[EMPTY_CELL, [10, 10, 10, 10], [15, 15, 14, 14], [11, 16, 11, 16], [12, 12, 12, 12], FREE_CELL],
	[EMPTY_CELL, [15, 16, 15, 16], FREE_CELL, EMPTY_CELL, [14, 10, 11, 11], FREE_CELL],
	[EMPTY_CELL, [11, 11, 10, 16], [10, 10, 13, 13], [11, 11, 10, 10], [15, 15, 14, 14], [10, 14, 10, 14]],
	[EMPTY_CELL, EMPTY_CELL, [15, 10, 11, 11], [11, 11, 15, 12], [16, 10, 15, 10], EMPTY_CELL]],

	[[EMPTY_CELL, [16, 10, 15, 10], [16, 10, 14, 11], FREE_CELL, [16, 17, 16, 17], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [12, 15, 16, 10], FREE_CELL, [2, 2, 2, 2], [12, 11, 12, 11]],
	[EMPTY_CELL, FREE_CELL, [10, 12, 11, 14], [11, 14, 13, 15], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [10, 11, 14, 13], [13, 11, 17, 10], [17, 17, 11, 15], FREE_CELL, [15, 12, 11, 12]],
	[EMPTY_CELL, [13, 11, 13, 11], [2, 2, 2, 2], [12, 10, 15, 17], [17, 12, 10, 14], [15, 15, 17, 16]],
	[EMPTY_CELL, [12, 12, 11, 11], [14, 17, 15, 10], [12, 12, 16, 16], FREE_CELL, FREE_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL, [12, 12, 14, 14], [16, 10, 11, 13]],
	[EMPTY_CELL, EMPTY_CELL, [11, 13, 10, 14], [14, 12, 11, 10], [11, 16, 13, 14], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, [13, 13, 16, 16], FREE_CELL, FREE_CELL, [10, 14, 11, 16]],
	[EMPTY_CELL, EMPTY_CELL, [11, 13, 14, 10], FREE_CELL, [14, 16, 10, 11], [12, 11, 10, 11]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [15, 10, 12, 14], [11, 13, 16, 16], [15, 10, 13, 14], [15, 13, 12, 12], EMPTY_CELL],
	[EMPTY_CELL, [13, 13, 16, 12], FREE_CELL, [10, 16, 15, 11], FREE_CELL, [16, 16, 13, 13]],
	[EMPTY_CELL, [11, 11, 15, 16], FREE_CELL, FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [10, 11, 10, 14], [15, 16, 13, 10], [12, 14, 15, 11], FREE_CELL, [11, 16, 12, 13]],
	[EMPTY_CELL, EMPTY_CELL, [16, 15, 16, 15], [13, 13, 13, 13], [12, 12, 12, 12], [14, 14, 14, 14]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],   #10 уровень

	[[EMPTY_CELL, [16, 13, 12, 12], [10, 14, 10, 14], FREE_CELL, FREE_CELL, [14, 12, 14, 10]],
	[EMPTY_CELL, [16, 13, 11, 11], [15, 11, 15, 11], FREE_CELL, [12, 15, 10, 16], [10, 13, 11, 15]],
	[EMPTY_CELL, [10, 10, 16, 16], [12, 10, 13, 15], FREE_CELL, [14, 15, 10, 13], [12, 12, 15, 15]],
	[EMPTY_CELL, FREE_CELL, [16, 12, 16, 12], [16, 14, 13, 10], FREE_CELL, [16, 13, 15, 14]],
	[EMPTY_CELL, [14, 14, 16, 16], [10, 10, 10, 10], [15, 15, 11, 11], [13, 16, 12, 10], FREE_CELL],
	[EMPTY_CELL, [12, 10, 13, 15], [14, 16, 14, 16], [15, 10, 13, 16], [16, 12, 15, 11], [13, 12, 16, 12]]],

	[[EMPTY_CELL, [17, 10, 14, 16], [15, 12, 13, 16], FREE_CELL, [14, 10, 14, 17], FREE_CELL],
	[EMPTY_CELL, [11, 13, 16, 10], FREE_CELL, FREE_CELL, FREE_CELL, [11, 17, 11, 12]],
	[EMPTY_CELL, [10, 13, 10, 13], [16, 11, 17, 11], EMPTY_CELL, [14, 12, 16, 12], [16, 16, 16, 16]],
	[EMPTY_CELL, [15, 14, 15, 14], [15, 14, 15, 14], [2, 2, 2, 2], [10, 10, 10, 10], [11, 11, 16, 16]],
	[EMPTY_CELL, FREE_CELL, [16, 16, 14, 13], [11, 12, 11, 12], [11, 11, 15, 15], [14, 13, 12, 13]],
	[EMPTY_CELL, [13, 11, 17, 12], [17, 10, 13, 13], FREE_CELL, FREE_CELL, [11, 11, 14, 14]]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [14, 14, 14, 14], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL, [12, 12, 12, 12]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, [16, 13, 15, 15], FREE_CELL, [17, 12, 17, 10], EMPTY_CELL],
	[EMPTY_CELL, [11, 11, 11, 11], [17, 17, 17, 17], [13, 16, 12, 12], FREE_CELL, [16, 14, 16, 10]],
	[EMPTY_CELL, FREE_CELL, [13, 13, 12, 11], FREE_CELL, [15, 13, 16, 12], FREE_CELL],
	[EMPTY_CELL, [11, 11, 17, 17], [10, 16, 10, 11], [13, 13, 10, 14], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [13, 13, 15, 15], [10, 14, 10, 14], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, [11, 11, 11, 11], [17, 13, 12, 12], [14, 11, 14, 11], EMPTY_CELL]],

	[[EMPTY_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL, [17, 14, 17, 14], FREE_CELL],
	[EMPTY_CELL, [17, 15, 11, 14], FREE_CELL, FREE_CELL, [15, 16, 15, 16], FREE_CELL],
	[EMPTY_CELL, [15, 10, 13, 13], [2, 2, 2, 2], [17, 17, 13, 15], FREE_CELL, [14, 13, 17, 13]],
	[EMPTY_CELL, [17, 16, 17, 12], FREE_CELL, [12, 16, 10, 14], [2, 2, 2, 2], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [11, 12, 10, 13], [14, 11, 17, 11], [13, 13, 14, 12], [12, 10, 11, 17]],
	[EMPTY_CELL, [16, 13, 17, 10], FREE_CELL, EMPTY_CELL, FREE_CELL, [14, 11, 13, 11]]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [13, 10, 15, 15], [12, 15, 12, 13]],
	[[17, 13, 14, 13], FREE_CELL, [14, 14, 14, 14], EMPTY_CELL, [14, 14, 16, 10], [11, 14, 11, 14]],
	[[11, 15, 10, 13], FREE_CELL, [13, 13, 21, 15], [212, 212, 212, 212], [13, 13, 13, 13], [16, 16, 16, 16]],
	[[14, 16, 14, 16], [10, 10, 15, 13], [14, 14, 15, 11], EMPTY_CELL, [15, 14, 12, 14], [12, 14, 13, 14]],
	[[15, 13, 15, 14], FREE_CELL, FREE_CELL, EMPTY_CELL, [10, 10, 15, 15], [16, 12, 14, 15]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL, [12, 15, 11, 11], [16, 13, 12, 14]],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL, [16, 13, 16, 13], [10, 15, 10, 13]],
	[EMPTY_CELL, FREE_CELL, [10, 22, 16, 14], [2, 2, 2, 2], [10, 10, 16, 12], [15, 11, 14, 10]],
	[EMPTY_CELL, [12, 12, 12, 12], [14, 15, 14, 11], [210, 213, 216, 213], [11, 14, 15, 15], [12, 12, 11, 11]],
	[EMPTY_CELL, [14, 11, 33, 11], [15, 15, 12, 12], FREE_CELL, [316, 313, 312, 314], [14, 12, 15, 12]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [16, 10, 16, 10], [17, 13, 12, 16], [35, 10, 13, 13], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [11, 11, 12, 12], [13, 13, 13, 13], [14, 12, 15, 15], [16, 16, 12, 12], [17, 17, 13, 13]],
	[EMPTY_CELL, [15, 17, 15, 11], [316, 313, 311, 311], FREE_CELL, [216, 213, 211, 211], [15, 15, 11, 11]],
	[EMPTY_CELL, [10, 10, 13, 13], FREE_CELL, [2, 2, 2, 2], FREE_CELL, [12, 14, 12, 14]],
	[EMPTY_CELL, [17, 17, 11, 11], [14, 14, 13, 13], EMPTY_CELL, [13, 10, 14, 10], FREE_CELL],
	[EMPTY_CELL, [14, 13, 12, 12], [25, 14, 17, 14], FREE_CELL, [17, 17, 11, 11], [13, 16, 14, 15]]],

	[[EMPTY_CELL, [12, 16, 13, 15], FREE_CELL, FREE_CELL, FREE_CELL, [10, 15, 10, 16]],
	[EMPTY_CELL, [11, 10, 12, 10], FREE_CELL, [11, 15, 11, 15], [17, 14, 10, 13], [17, 10, 14, 11]],
	[EMPTY_CELL, FREE_CELL, [16, 16, 17, 17], [10, 16, 10, 16], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [12, 12, 17, 17], [11, 11, 11, 11], [17, 17, 16, 13], FREE_CELL],
	[EMPTY_CELL, [13, 14, 13, 11], [10, 15, 16, 13], FREE_CELL, [14, 17, 13, 11], [10, 11, 10, 12]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [17, 12, 10, 12], FREE_CELL, FREE_CELL, [12, 13, 11, 14], EMPTY_CELL],
	[EMPTY_CELL, [16, 13, 12, 17], FREE_CELL, [14, 11, 16, 16], FREE_CELL, [17, 16, 13, 12]],
	[EMPTY_CELL, [17, 11, 17, 11], FREE_CELL, [2, 2, 2, 2], [12, 12, 16, 16], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [15, 10, 17, 11], EMPTY_CELL, [12, 12, 12, 12], [16, 16, 14, 15]],    #20 уровень
	[EMPTY_CELL, [14, 14, 15, 15], FREE_CELL, [12, 13, 16, 10], [17, 17, 15, 15], [13, 13, 14, 14]],
	[EMPTY_CELL, EMPTY_CELL, [10, 10, 16, 13], FREE_CELL, [14, 12, 15, 11], FREE_CELL]],

	[[EMPTY_CELL, [16, 10, 15, 10], [16, 13, 16, 17], FREE_CELL, FREE_CELL, [11, 12, 13, 13]],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [12, 17, 15, 13], [16, 16, 10, 10], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [11, 17, 11, 10], FREE_CELL, [16, 16, 14, 14]],
	[EMPTY_CELL, [14, 10, 14, 16], [15, 10, 17, 10], FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [16, 16, 11, 11], FREE_CELL, [12, 12, 10, 14], [10, 10, 12, 15]],
	[EMPTY_CELL, [11, 11, 12, 15], [14, 10, 14, 17], FREE_CELL, FREE_CELL, [10, 10, 13, 17]]],

	[[EMPTY_CELL, FREE_CELL, [45, 13, 16, 14], FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, [14, 13, 10, 10], FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, [12, 12, 35, 35], [16, 16, 12, 12], FREE_CELL, [312, 313, 315, 315], [14, 12, 14, 13]],
	[EMPTY_CELL, [13, 12, 11, 11], [14, 14, 14, 14], [16, 16, 11, 11], [12, 12, 12, 12], [11, 12, 16, 16]],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, [211, 215, 211, 214], FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, [10, 23, 10, 23], [10, 10, 14, 14], [15, 15, 11, 13], [414, 415, 414, 416], [16, 13, 11, 14]]],

	[[EMPTY_CELL, FREE_CELL, EMPTY_CELL, [14, 11, 12, 15], EMPTY_CELL, [13, 16, 15, 12]],
	[EMPTY_CELL, [14, 16, 33, 11], [17, 17, 17, 17], FREE_CELL, FREE_CELL, [16, 15, 10, 15]],
	[EMPTY_CELL, FREE_CELL, [310, 316, 314, 314], [15, 15, 12, 16], [211, 217, 210, 210], [11, 13, 14, 14]],
	[EMPTY_CELL, [17, 16, 14, 10], [15, 12, 14, 12], [2, 2, 2, 2], [17, 16, 11, 14], FREE_CELL],
	[EMPTY_CELL, [11, 11, 16, 14], FREE_CELL, [412, 413, 412, 410], [17, 12, 11, 11], FREE_CELL],
	[EMPTY_CELL, [13, 42, 11, 42], [16, 14, 17, 10], FREE_CELL, [17, 13, 10, 16], [16, 14, 20, 17]]],

	[[EMPTY_CELL, EMPTY_CELL, [14, 13, 14, 13], [10, 10, 10, 10], [14, 13, 14, 13], EMPTY_CELL],
	[EMPTY_CELL, FREE_CELL, [16, 16, 11, 11], [13, 16, 14, 11], FREE_CELL, [14, 10, 11, 16]],
	[EMPTY_CELL, FREE_CELL, [14, 14, 14, 14], [10, 10, 13, 13], FREE_CELL, [16, 10, 13, 13]],
	[EMPTY_CELL, FREE_CELL, [16, 11, 16, 11], [16, 16, 10, 10], FREE_CELL, [16, 16, 10, 10]],
	[EMPTY_CELL, [11, 16, 11, 16], FREE_CELL, [14, 16, 14, 16], FREE_CELL, [16, 14, 11, 11]],
	[EMPTY_CELL, EMPTY_CELL, [10, 10, 16, 16], [11, 14, 11, 14], [13, 13, 11, 10], EMPTY_CELL]],

	[[EMPTY_CELL, [11, 11, 16, 12], [14, 11, 14, 11], FREE_CELL, [10, 14, 10, 16], [15, 15, 10, 10]],
	[EMPTY_CELL, [10, 10, 16, 16], [2, 2, 2, 2], FREE_CELL, [14, 14, 16, 16], FREE_CELL],
	[EMPTY_CELL, [30, 14, 15, 15], FREE_CELL, [15, 16, 15, 16], [14, 15, 13, 15], FREE_CELL],
	[EMPTY_CELL, [16, 16, 10, 10], FREE_CELL, [216, 210, 214, 210], FREE_CELL, [14, 11, 10, 23]],
	[EMPTY_CELL, [12, 14, 12, 14], [312, 315, 312, 315], [11, 12, 14, 14], [2, 2, 2, 2], [16, 16, 15, 15]],
	[EMPTY_CELL, [16, 16, 13, 13], [14, 14, 12, 12], [12, 10, 13, 13], FREE_CELL, [10, 10, 14, 14]]],    #25 уровень

	[[EMPTY_CELL, FREE_CELL, [11, 17, 14, 10], [15, 15, 14, 14], [17, 11, 17, 16], [13, 12, 11, 15]],
	[EMPTY_CELL, [10, 16, 15, 14], FREE_CELL, FREE_CELL, [13, 14, 13, 14], [10, 16, 13, 13]],
	[EMPTY_CELL, EMPTY_CELL, [11, 15, 16, 14], FREE_CELL, [16, 15, 11, 10], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [14, 16, 14, 12], [10, 14, 11, 12], [10, 13, 14, 17], EMPTY_CELL],
	[EMPTY_CELL, [16, 14, 10, 11], FREE_CELL, [17, 11, 16, 11], FREE_CELL, [12, 12, 13, 13]],
	[EMPTY_CELL, [12, 17, 12, 13], [11, 15, 14, 10], FREE_CELL, [16, 14, 15, 15], FREE_CELL]],

	[[EMPTY_CELL, [12, 12, 12, 12], [11, 13, 11, 13], FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [16, 14, 10, 14], [12, 15, 12, 15], [11, 14, 11, 35]],
	[EMPTY_CELL, [21, 10, 15, 12], FREE_CELL, FREE_CELL, [14, 14, 14, 14], [16, 13, 10, 15]],
	[EMPTY_CELL, [14, 14, 12, 12], [13, 11, 13, 11], [212, 211, 213, 211], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [11, 15, 12, 15], FREE_CELL, [14, 13, 14, 13], [316, 310, 316, 310], FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, [12, 12, 12, 12], FREE_CELL, [12, 12, 10, 13], EMPTY_CELL]],

	[[EMPTY_CELL, [36, 10, 36, 10], FREE_CELL, [15, 27, 13, 13], [11, 11, 11, 11], [16, 16, 13, 11]],
	[EMPTY_CELL, FREE_CELL, [13, 10, 15, 10], FREE_CELL, [13, 16, 13, 16], [45, 45, 13, 12]],
	[EMPTY_CELL, EMPTY_CELL, [216, 216, 212, 212], EMPTY_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [16, 16, 12, 17], [11, 17, 13, 15], [2, 2, 2, 2], [313, 314, 312, 310], [416, 410, 411, 415]],
	[EMPTY_CELL, [14, 12, 13, 16], [15, 13, 14, 14], [14, 16, 13, 10], FREE_CELL, [14, 16, 11, 17]],
	[EMPTY_CELL, FREE_CELL, [17, 11, 10, 10], [12, 12, 13, 13], [15, 12, 17, 16], [10, 13, 10, 14]]],

	[[EMPTY_CELL, FREE_CELL, [16, 10, 16, 10], FREE_CELL, [14, 12, 13, 16], [13, 17, 13, 14]],
	[EMPTY_CELL, FREE_CELL, [10, 11, 10, 11], [2, 2, 2, 2], [17, 17, 10, 10], FREE_CELL],
	[EMPTY_CELL, [14, 12, 10, 11], FREE_CELL, [1016, 1014, 1016, 1014], [15, 15, 12, 12], [16, 13, 17, 13]],
	[EMPTY_CELL, [13, 14, 13, 14], FREE_CELL, [12, 12, 11, 11], FREE_CELL, [11, 10, 14, 15]],
	[EMPTY_CELL, [15, 15, 17, 15], FREE_CELL, [2, 2, 2, 2], [11, 11, 11, 11], [15, 10, 15, 10]],
	[EMPTY_CELL, [10, 10, 10, 10], FREE_CELL, [13, 13, 16, 14], FREE_CELL, [13, 13, 15, 15]]],

	[[EMPTY_CELL, [10, 14, 13, 14], [17, 10, 11, 14], [15, 15, 16, 16], [23, 17, 15, 17], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [310, 315, 312, 312], [16, 16, 16, 16], [10, 10, 10, 10]],
	[EMPTY_CELL, FREE_CELL, [1017, 1013, 1017, 1011], FREE_CELL, [15, 15, 16, 10], FREE_CELL],
	[EMPTY_CELL, [210, 212, 210, 212], FREE_CELL, [11, 11, 17, 17], [30, 17, 12, 17], FREE_CELL],
	[EMPTY_CELL, [11, 11, 12, 15], FREE_CELL, [12, 13, 12, 13], FREE_CELL, [10, 14, 10, 14]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],   #30 уровень

	[[EMPTY_CELL, [14, 13, 14, 13], FREE_CELL, [12, 13, 12, 13], FREE_CELL, [16, 16, 16, 16]],
	[EMPTY_CELL, [17, 15, 10, 13], [10, 16, 10, 16], [17, 17, 17, 17], [15, 15, 14, 14], [10, 14, 10, 14]],
	[EMPTY_CELL, FREE_CELL, [17, 11, 17, 11], [2, 2, 2, 2], FREE_CELL, [1014, 1015, 1014, 1016]],
	[EMPTY_CELL, [14, 13, 14, 13], [14, 14, 14, 14], FREE_CELL, [12, 11, 12, 11], FREE_CELL],
	[EMPTY_CELL, [16, 16, 12, 12], [17, 10, 17, 10], [15, 15, 16, 12], FREE_CELL, [13, 10, 13, 10]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, FREE_CELL, [11, 11, 11, 11], [1013, 1011, 1014, 1016], FREE_CELL, [14, 13, 10, 11]],
	[EMPTY_CELL, [30, 13, 30, 13], FREE_CELL, FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [316, 316, 316, 316], EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, [214, 213, 211, 211]],
	[EMPTY_CELL, FREE_CELL, [11, 10, 11, 10], FREE_CELL, [14, 14, 16, 16], FREE_CELL],
	[EMPTY_CELL, [16, 16, 14, 14], FREE_CELL, [10, 11, 10, 11], FREE_CELL, [16, 23, 16, 23]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL, [11, 13, 11, 12], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [1012, 1014, 1012, 1013], FREE_CELL, [12, 12, 13, 14]],
	[EMPTY_CELL, [12, 11, 10, 11], [14, 12, 14, 12], [10, 10, 10, 10], [13, 14, 12, 12], FREE_CELL],
	[EMPTY_CELL, [13, 13, 11, 16], FREE_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [12, 12, 16, 13], FREE_CELL, EMPTY_CELL, [11, 11, 10, 16], [13, 13, 13, 13]]],

	[[EMPTY_CELL, FREE_CELL, FREE_CELL, [12, 15, 11, 17], [17, 10, 16, 16], [14, 15, 12, 17]],
	[EMPTY_CELL, [17, 31, 15, 10], [12, 10, 14, 11], [313, 310, 317, 312], FREE_CELL, [17, 12, 17, 12]],
	[EMPTY_CELL, [12, 11, 13, 14], [2, 2, 2, 2], [16, 10, 14, 10], [2, 2, 2, 2], [16, 16, 17, 13]],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [215, 216, 215, 217], FREE_CELL, [14, 22, 10, 16]],
	[EMPTY_CELL, [15, 10, 17, 11], [12, 13, 10, 15], [1012, 1014, 1012, 1011], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, [16, 10, 16, 10], FREE_CELL, [12, 16, 13, 13], [11, 11, 14, 15], [14, 12, 13, 11]],
	[EMPTY_CELL, [14, 13, 14, 13], FREE_CELL, FREE_CELL, [11, 13, 16, 12], [15, 16, 11, 13]],
	[EMPTY_CELL, [13, 11, 15, 16], [1010, 1012, 1014, 1012], [15, 12, 11, 16], [14, 16, 14, 16], [10, 16, 13, 13]],
	[EMPTY_CELL, [16, 11, 12, 14], FREE_CELL, [15, 12, 15, 12], FREE_CELL, [12, 10, 14, 13]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],   #35 уровень

	[[EMPTY_CELL, [11, 10, 16, 16], [11, 13, 11, 14], [11, 16, 10, 16], [14, 16, 11, 10], [11, 10, 13, 16]],
	[EMPTY_CELL, FREE_CELL, [2, 2, 2, 2], FREE_CELL, EMPTY_CELL, [11, 11, 10, 10]],
	[EMPTY_CELL, [16, 10, 11, 10], [16, 14, 11, 11], FREE_CELL, [14, 16, 14, 16], FREE_CELL],
	[EMPTY_CELL, [10, 11, 13, 11], [16, 13, 16, 13], [2, 2, 2, 2], FREE_CELL, [14, 14, 16, 13]],
	[EMPTY_CELL, [10, 14, 16, 16], [13, 14, 13, 14], FREE_CELL, [16, 13, 16, 11], [10, 16, 10, 14]],
	[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, FREE_CELL, [13, 11, 14, 11], FREE_CELL, [12, 12, 10, 15], [16, 14, 10, 15]],
	[EMPTY_CELL, [10, 10, 12, 12], EMPTY_CELL, [15, 15, 15, 15], [14, 14, 10, 10], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [1011, 1011, 1015, 1010], FREE_CELL, [12, 12, 14, 10]],
	[EMPTY_CELL, [11, 11, 12, 13], [14, 16, 12, 12], [10, 13, 10, 13], [10, 15, 11, 11], [13, 13, 13, 13]],
	[EMPTY_CELL, [16, 14, 10, 15], FREE_CELL, FREE_CELL, [2, 2, 2, 2], [16, 10, 12, 13]],
	[EMPTY_CELL, [16, 11, 14, 11], [12, 12, 14, 13], FREE_CELL, FREE_CELL, [16, 16, 12, 15]]],

	[[FREE_CELL, [15, 10, 13, 14], [11, 13, 11, 14], [14, 17, 15, 12], [11, 14, 11, 13], [10, 15, 16, 17]],
	[FREE_CELL, EMPTY_CELL, [10, 13, 17, 17], [17, 16, 14, 14], [2, 2, 2, 2], [13, 11, 13, 15]],
	[[12, 12, 13, 16], [417, 415, 412, 412], [12, 12, 16, 16], FREE_CELL, [13, 13, 10, 15], [17, 17, 14, 16]],
	[[10, 10, 43, 11], FREE_CELL, [313, 314, 313, 314], [36, 36, 11, 15], [17, 17, 16, 13], [213, 217, 212, 210]],
	[FREE_CELL, [2, 2, 2, 2], FREE_CELL, FREE_CELL, EMPTY_CELL, FREE_CELL],
	[[10, 10, 27, 27], FREE_CELL, [1011, 1017, 1011, 1015], FREE_CELL, [17, 17, 17, 17], [10, 15, 16, 17]]],

	[[EMPTY_CELL, EMPTY_CELL, [17, 17, 10, 12], [16, 11, 13, 15], FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, [16, 13, 14, 11], FREE_CELL, [15, 14, 12, 13], [16, 17, 12, 11], FREE_CELL],
	[EMPTY_CELL, [12, 14, 15, 14], [16, 16, 10, 13], [2, 2, 2, 2], FREE_CELL, [1012, 1012, 1011, 1011]],
	[EMPTY_CELL, FREE_CELL, [16, 15, 13, 15], [11, 17, 11, 14], [13, 13, 12, 11], [16, 15, 14, 14]],
	[EMPTY_CELL, [11, 14, 12, 15], [1011, 1011, 1017, 1014], [16, 16, 17, 17], [17, 10, 16, 11], [15, 17, 14, 10]],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, FREE_CELL, FREE_CELL, EMPTY_CELL]],

	[[EMPTY_CELL, [11, 15, 10, 13], [13, 12, 14, 15], FREE_CELL, [13, 10, 14, 12], EMPTY_CELL],
	[[2, 2, 2, 2], [13, 16, 13, 16], [11, 12, 14, 16], [10, 14, 12, 16], [12, 13, 11, 10], FREE_CELL],
	[[14, 10, 15, 13], [16, 13, 11, 11], [16, 13, 10, 10], [11, 13, 12, 15], FREE_CELL, [12, 14, 13, 13]],
	[[10, 11, 10, 14], [16, 15, 13, 10], [12, 16, 11, 14], FREE_CELL, FREE_CELL, [16, 14, 12, 15]],
	[[15, 15, 11, 16], [11, 11, 13, 13], [15, 16, 14, 10], FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [10, 16, 14, 14], [12, 16, 12, 10], [13, 16, 12, 10], [10, 16, 11, 14], EMPTY_CELL]],   #40 уровень

	[[EMPTY_CELL, [12, 12, 31, 31], FREE_CELL, [13, 12, 13, 12], [10, 12, 13, 12], [25, 14, 13, 13]],
	[EMPTY_CELL, [14, 14, 16, 15], FREE_CELL, [17, 15, 16, 13], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [15, 17, 17, 17], EMPTY_CELL, FREE_CELL, [1012, 1012, 1013, 1016], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, [13, 13, 12, 17], FREE_CELL, [2, 2, 2, 2], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, FREE_CELL, [215, 212, 217, 217], [14, 10, 14, 10]],
	[EMPTY_CELL, [14, 15, 12, 16], [12, 12, 17, 17], [313, 315, 313, 315], [13, 15, 12, 16], [17, 16, 17, 10]]],

	[[EMPTY_CELL, FREE_CELL, [10, 13, 10, 16], [14, 12, 15, 17], [11, 14, 10, 14], EMPTY_CELL],
	[[15, 11, 10, 16], [212, 212, 212, 212], [14, 14, 16, 16], [36, 13, 12, 14], FREE_CELL, FREE_CELL],
	[[13, 13, 16, 15], [10, 16, 12, 14], [312, 314, 313, 315], FREE_CELL, [14, 16, 11, 17], [12, 16, 10, 11]],
	[[11, 12, 14, 14], [16, 12, 16, 12], FREE_CELL, [1011, 1010, 1013, 1015], [15, 40, 12, 12], [11, 14, 11, 14]],
	[[10, 12, 10, 14], [413, 410, 415, 416], FREE_CELL, [10, 11, 10, 11], FREE_CELL, [10, 12, 10, 12]],
	[EMPTY_CELL, FREE_CELL, [15, 17, 10, 10], FREE_CELL, [14, 11, 17, 25], EMPTY_CELL]],

	[[[17, 16, 13, 11], [13, 13, 17, 17], [1017, 1011, 1010, 1011], FREE_CELL, [14, 13, 14, 16], [10, 12, 10, 12]],
	[FREE_CELL, FREE_CELL, EMPTY_CELL, [2, 2, 2, 2], FREE_CELL, [17, 17, 17, 17]],
	[[10, 15, 16, 14], [10, 12, 10, 14], [14, 14, 10, 10], [16, 15, 13, 10], [14, 15, 14, 15], [13, 14, 12, 10]],
	[FREE_CELL, [13, 11, 16, 14], [17, 15, 16, 11], FREE_CELL, [17, 17, 12, 12], FREE_CELL],
	[[1015, 1016, 1014, 1017], FREE_CELL, EMPTY_CELL, EMPTY_CELL, [16, 13, 11, 15], [11, 15, 11, 10]],
	[[10, 13, 12, 12], FREE_CELL, FREE_CELL, FREE_CELL, [13, 12, 13, 12], [15, 15, 11, 12]]],

	[[EMPTY_CELL, FREE_CELL, FREE_CELL, [15, 13, 14, 10], FREE_CELL, [13, 11, 13, 11]],
	[EMPTY_CELL, [11, 13, 10, 10], [12, 12, 13, 13], [16, 16, 14, 14], [13, 14, 12, 15], [16, 12, 14, 13]],
	[EMPTY_CELL, [16, 16, 16, 16], [14, 14, 14, 14], [2, 2, 2, 2], FREE_CELL, [13, 14, 16, 15]],
	[EMPTY_CELL, FREE_CELL, [12, 11, 15, 11], EMPTY_CELL, FREE_CELL, [11, 13, 15, 12]],
	[EMPTY_CELL, [14, 12, 10, 10], FREE_CELL, [1012, 1014, 1011, 1013], FREE_CELL, [11, 16, 12, 13]],
	[EMPTY_CELL, [11, 13, 11, 13], FREE_CELL, [15, 16, 14, 12], [10, 10, 11, 12], [16, 15, 10, 12]]],

	[[FREE_CELL, [11, 22, 13, 22], [15, 15, 16, 16], [11, 35, 14, 12], [16, 16, 15, 17], FREE_CELL],
	[FREE_CELL, EMPTY_CELL, [17, 17, 17, 17], [12, 16, 13, 13], EMPTY_CELL, [15, 15, 17, 17]],
	[[16, 17, 11, 15], FREE_CELL, [14, 14, 14, 14], FREE_CELL, [10, 11, 15, 12], [15, 15, 15, 15]],
	[[216, 212, 210, 214], [15, 13, 12, 16], [12, 12, 14, 14], [314, 314, 312, 312], [17, 17, 16, 14], [16, 14, 16, 14]],   #45 уровень
	[FREE_CELL, EMPTY_CELL, [16, 16, 12, 15], FREE_CELL, EMPTY_CELL, FREE_CELL],
	[[11, 16, 12, 15], [15, 12, 13, 16], [11, 10, 14, 16], FREE_CELL, [14, 10, 12, 10], FREE_CELL]],

	[[EMPTY_CELL, EMPTY_CELL, [12, 34, 16, 10], [15, 14, 15, 14], [11, 14, 20, 16], EMPTY_CELL],
	[EMPTY_CELL, FREE_CELL, [40, 11, 12, 15], EMPTY_CELL, [15, 11, 14, 12], FREE_CELL],
	[EMPTY_CELL, [16, 16, 13, 13], FREE_CELL, FREE_CELL, [12, 14, 10, 13], FREE_CELL],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [16, 16, 14, 15], FREE_CELL, [413, 412, 413, 416]],
	[EMPTY_CELL, [1011, 1012, 1016, 1015], [210, 212, 210, 212], [2, 2, 2, 2], [313, 310, 312, 314], [14, 12, 10, 15]],
	[EMPTY_CELL, EMPTY_CELL, [14, 10, 13, 15], [14, 11, 12, 13], [16, 10, 14, 10], EMPTY_CELL]],

	[[EMPTY_CELL, [13, 16, 13, 16], FREE_CELL, [13, 11, 10, 11], FREE_CELL, [11, 22, 15, 14]],
	[EMPTY_CELL, EMPTY_CELL, [10, 12, 10, 12], FREE_CELL, [1012, 1012, 1011, 1011], EMPTY_CELL],
	[EMPTY_CELL, [13, 13, 14, 10], FREE_CELL, [16, 11, 16, 11], [10, 15, 10, 15], FREE_CELL],
	[EMPTY_CELL, [16, 14, 10, 14], FREE_CELL, [10, 12, 14, 11], FREE_CELL, [15, 14, 16, 14]],
	[EMPTY_CELL, EMPTY_CELL, [14, 16, 12, 12], [215, 210, 215, 212], FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, FREE_CELL, [11, 10, 15, 15], [12, 15, 13, 14], [11, 11, 16, 12], [16, 10, 16, 10]]],

	[[[2015, 2015, 2017, 2016], [2014, 2010, 2014, 2015], [2010, 2011, 2010, 2011], [2012, 2012, 2011, 2013], FREE_CELL, [2014, 2014, 2014, 2014]],
	[[2016, 2014, 2011, 2014], FREE_CELL, [2014, 2012, 2014, 2012], [2012, 2012, 2010, 2016], FREE_CELL, EMPTY_CELL],
	[[2011, 2013, 2012, 2013], [2012, 2013, 2015, 2014], [2014, 2014, 2015, 2010], [2016, 2016, 2016, 2016], FREE_CELL, FREE_CELL],
	[[2013, 2013, 2017, 2017], FREE_CELL, FREE_CELL, FREE_CELL, FREE_CELL, FREE_CELL],
	[EMPTY_CELL, EMPTY_CELL, FREE_CELL, [14, 12, 14, 12], FREE_CELL, FREE_CELL],
	[FREE_CELL, [17, 10, 17, 14], FREE_CELL, FREE_CELL, [16, 16, 16, 16], [12, 12, 11, 11]]],

	[[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL, FREE_CELL, EMPTY_CELL, EMPTY_CELL],
	[EMPTY_CELL, EMPTY_CELL, [2012, 2012, 2015, 2015], [2010, 2013, 2015, 2017], FREE_CELL, EMPTY_CELL],
	[EMPTY_CELL, [2014, 2016, 2012, 2015], [2016, 2015, 2016, 2015], FREE_CELL, [2012, 2014, 2017, 2010], [2017, 2014, 2010, 2016]],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, [2, 2, 2, 2], FREE_CELL, FREE_CELL],
	[EMPTY_CELL, [14, 16, 15, 12], [13, 15, 11, 11], [13, 12, 13, 11], FREE_CELL, [17, 12, 17, 12]],
	[EMPTY_CELL, FREE_CELL, FREE_CELL, FREE_CELL, [1015, 1015, 1011, 1011], FREE_CELL]],

	[[[16, 12, 11, 12], [13, 11, 14, 17], FREE_CELL, [15, 16, 11, 13], FREE_CELL, [16, 31, 10, 31]],
	[FREE_CELL, [15, 16, 11, 11], [10, 10, 10, 10], [12, 15, 16, 11], EMPTY_CELL, FREE_CELL],
	[[44, 15, 13, 11], FREE_CELL, [216, 215, 211, 213], EMPTY_CELL, [10, 10, 10, 10], [12, 13, 16, 11]],
	[[14, 14, 13, 11], FREE_CELL, [2, 2, 2, 2], [13, 11, 16, 11], FREE_CELL, FREE_CELL],
	[[12, 17, 15, 17], EMPTY_CELL, [313, 311, 316, 310], FREE_CELL, [413, 411, 416, 417], FREE_CELL],
	[FREE_CELL, [12, 14, 10, 10], [15, 12, 15, 12], [13, 10, 13, 11], [14, 11, 14, 11], [14, 16, 25, 12]]]   #50 уровень
]
