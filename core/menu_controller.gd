extends Control

func _ready() -> void:
	$continue.visible = SaveManager.has_save()
	$newgame.visible = true

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/MainLevel.tscn")

func _on_newgame_pressed() -> void:
	LevelManager.reset()
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://ui/new_gameone.tscn")
