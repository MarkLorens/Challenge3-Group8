extends Control

func _input(event):

	if event is InputEventScreenTouch and event.pressed:
		start_game()

	if event is InputEventMouseButton and event.pressed:
		start_game()


func start_game():
	get_tree().change_scene_to_file("res://ui/menu.tscn")
