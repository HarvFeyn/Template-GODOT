class_name OptionsMenu
extends Control

@onready var _master_slider: HSlider = $VBoxContainer/MasterSlider
@onready var _music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var _sfx_slider: HSlider = $VBoxContainer/SFXSlider

var context: Enums.OptionsContext = Enums.OptionsContext.MAIN_MENU
signal closed

func _ready() -> void:
	_master_slider.value = AudioManager.get_volume(AudioManager.BUS_MASTER)
	_music_slider.value = AudioManager.get_volume(AudioManager.BUS_MUSIC)
	_sfx_slider.value = AudioManager.get_volume(AudioManager.BUS_SFX)

func _on_master_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MASTER, value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MUSIC, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_SFX, value)

func _on_fullscreen_check_box_toggled(value: bool) -> void:
	Globals.set_fullscreen(value)

func _on_back_button_pressed() -> void:
	SettingsManager.save()
	match context:
		Enums.OptionsContext.MAIN_MENU:
			SceneManager.go_to_main_menu()
		Enums.OptionsContext.PAUSE_MENU:
			closed.emit()
			queue_free()
