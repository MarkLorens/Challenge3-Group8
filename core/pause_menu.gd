extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	hide()

#func open_pause():
	#show()
	#get_tree().paused = true

func close_pause():
	hide()
	get_tree().paused = false

func _on_continue_pressed() -> void:
	close_pause()

func _on_restart_pressed() -> void:
	LevelManager.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_exit_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveManager.save_position(player.current_grid)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/menu.tscn")

func _on_pause_button_pressed() -> void:
	show() 
	get_tree().paused = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
