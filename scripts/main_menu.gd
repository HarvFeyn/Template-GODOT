class_name MainMenu
extends Control


func _on_button_pressed() -> void:
	SceneManager.go_to_game()

func _on_options_pressed() -> void:
	SceneManager.go_to_options()

func _on_quit_pressed() -> void:
	Globals.quit()
