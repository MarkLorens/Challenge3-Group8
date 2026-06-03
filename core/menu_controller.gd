extends Control

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/MainLevel.tscn") 
	
func _on_newgame_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/storywhildchair.tscn") 
