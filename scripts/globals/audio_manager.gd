# audio_manager.gd
extends Node

const BUS_MASTER: String = "Master"
const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"

func _ready() -> void:
	_apply_settings()

func set_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("AudioManager: bus '%s' introuvable !" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	SettingsManager.set_setting("audio", bus_name.to_lower(), value)

func get_volume(bus_name: String) -> float:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("AudioManager: bus '%s' introuvable !" % bus_name)
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _apply_settings() -> void:
	set_volume(BUS_MASTER, SettingsManager.get_setting("audio", "master"))
	set_volume(BUS_MUSIC, SettingsManager.get_setting("audio", "music"))
	set_volume(BUS_SFX, SettingsManager.get_setting("audio", "sfx"))
