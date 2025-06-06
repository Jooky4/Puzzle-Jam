class_name AudioManager extends Node

func set_mute(value: bool) -> void:
	AudioServer.set_bus_mute(0, value)


func play_sound(name: String) -> void:
	pass


func stop_sound(name: String) -> void:
	pass
