# game.gd
class_name Game
extends Node

const PAUSE_MENU: PackedScene = preload("res://scenes/menus/pause_menu.tscn")

var _pause_menu_instance: PauseMenu = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	if get_tree().paused:
		_close_pause_menu()
	else:
		_open_pause_menu()

func _open_pause_menu() -> void:
	Globals.pause()
	_pause_menu_instance = PAUSE_MENU.instantiate()
	add_child(_pause_menu_instance)

func _close_pause_menu() -> void:
	Globals.resume()
	if _pause_menu_instance != null:
		_pause_menu_instance.queue_free()
		_pause_menu_instance = null
