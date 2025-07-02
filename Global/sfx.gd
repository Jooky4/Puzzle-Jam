extends AudioManager

const DEBUG = false


var sfx_config = {
	"bomb": {
		"path": "res://Assets/sfx/bomb.ogg",
		"volume": 0,
		"pitch": 0.95,
		"sound": null,
	},
	"buy_buster": {
		"path": "res://Assets/sfx/buy_buster.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"click": {
		"path": "res://Assets/sfx/click_1.mp3",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_install": {
		"path": "res://Assets/sfx/cube_install.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_life_merge": {
		"path": "res://Assets/sfx/cube_life_merge.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_life_move": {
		"path": "res://Assets/sfx/cube_life_move.mp3",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_merge": {
		"path": "res://Assets/sfx/cube_merge.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_noneinstall": {
		"path": "res://Assets/sfx/cube_noneinstall.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"cube_take": {
		"path": "res://Assets/sfx/cube_take.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"defeat": {
		"path": "res://Assets/sfx/defeat.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"hammer": {
		"path": "res://Assets/sfx/hammer.ogg",
		"volume": 0,
		"pitch": 1.9, # питч подтянут под анимацию удара молота
		"sound": null,
	},
	"ice_1": {
		"path": "res://Assets/sfx/ice_1.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"ice_2": {
		"path": "res://Assets/sfx/ice_2.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"ice_3": {
		"path": "res://Assets/sfx/ice_3.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"ice_install": {
		"path": "res://Assets/sfx/ice_install.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"key_1": {
		"path": "res://Assets/sfx/key_1.ogg",
		"volume": 0,
		"pitch": 1.5,
		"sound": null,
	},
	"key_2": {
		"path": "res://Assets/sfx/key_2.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"money": {
		"path": "res://Assets/sfx/money.mp3",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"spinner": {
		"path": "res://Assets/sfx/spinner.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"target_1": {
		"path": "res://Assets/sfx/target_1.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"target_2": {
		"path": "res://Assets/sfx/target_2.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
	"victory": {
		"path": "res://Assets/sfx/victory.ogg",
		"volume": 0,
		"pitch": 1,
		"sound": null,
	},
}

func play_music() -> void:
	$Music01.play()


func _ready() -> void:
	play_music()


func stop_sound(name: String) -> void:
	if DEBUG:
		prints("SFX.stop_sound(%s)" % name)

	if not sfx_config.has(name):
		if DEBUG:
			prints("SFX sound not found", name)
		return

	if sfx_config.has(name) and sfx_config[name].sound:
		sfx_config[name].sound.stop()


func play_sound(name: String) -> void:
	if DEBUG:
		prints("SFX.play_sound(%s)" % name)

	if not sfx_config.has(name):
		if DEBUG:
			prints("SFX sound not found", name)
		return

	var sfx_c = sfx_config[name]

	if sfx_c.sound:
		sfx_c.sound.play()
	else:
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		asp.set_bus("SFX")
		asp.stream = load(sfx_c.path)
		asp.volume_db = sfx_c.volume
		asp.pitch_scale = sfx_c.pitch
		sfx_c.sound = asp
		sfx_c.sound.play()
