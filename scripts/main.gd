class_name MainScene
extends Node

@onready var scene_container: Node = $SceneContainer

func _ready() -> void:
	Globals.main = self
	Globals.set_fullscreen(SettingsManager.get_setting("video", "fullscreen"))
	SceneManager.init(scene_container)
