extends Control

func _ready() -> void:
	$VBoxContainer/continue.visible = SaveManager.has_save()
	
func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/MainLevel.tscn") 
	
func _on_newgame_pressed() -> void:
	SaveManager.delete_save() 
	get_tree().change_scene_to_file("res://ui/storywhildchair.tscn") 
