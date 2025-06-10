class_name AudioManager extends Node

func _ready() -> void:
	get_viewport().connect("focus_entered", _on_focus_entered)
	get_viewport().connect("focus_exited", _on_focus_exited)


func _on_focus_entered():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


func _on_focus_exited():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func set_mute(value: bool) -> void:
	AudioServer.set_bus_mute(0, value)


func play_sound(name: String) -> void:
	pass


func stop_sound(name: String) -> void:
	pass
