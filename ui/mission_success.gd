extends Control

@onready var star1 = $TextureRect/StarRow/Star1
@onready var star2 = $TextureRect/StarRow/Star2
@onready var star3 = $TextureRect/StarRow/Star3


@onready var tick_main  = $TextureRect/MissionList/CheckMain/TextureButton
@onready var tick_side1 = $TextureRect/MissionList/CheckMain2/TextureButton
@onready var tick_side2 = $TextureRect/MissionList/CheckMain3/TextureButton

@onready var label_main  = $TextureRect/MissionList/CheckMain/Label
@onready var label_side1 = $TextureRect/MissionList/CheckMain2/Label
@onready var label_side2 = $TextureRect/MissionList/CheckMain3/Label

@onready var play_again_btn = $TextureRect/PlayAgain
@onready var exit_btn       = $TextureRect/Exit

var tex_star_on = preload("res://assets/art/ui/StarMission.png")
var tex_vtick   = preload("res://assets/art/ui/vTick.png")

func _ready():
	play_again_btn.pressed.connect(_on_play_again_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	_setup_missions()
	_setup_stars()

func _setup_stars() -> void:
	var star_count = LevelManager.completed_objectives.size()
	var stars = [star1, star2, star3]
	for i in range(3):
		if i < star_count:
			stars[i].modulate = Color(1, 1, 1, 1)        # earned → terang
		else:
			stars[i].modulate = Color(0.35, 0.35, 0.35, 1) # belum → gelap

func _setup_missions() -> void:
	var completed = LevelManager.completed_objectives
	_set_tick(tick_main, true)
	_set_tick(tick_side1, "Side1" in completed)
	_set_tick(tick_side2, "Side2" in completed)

func _set_tick(tick_node: TextureButton, is_done: bool) -> void:
	if tick_node == null:
		return
	if is_done:
		tick_node.modulate = Color(1, 1, 1, 1)      
	else:
		tick_node.modulate = Color(1, 1, 1, 0.15)   

func _on_play_again_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveManager.save_position(player.current_grid)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/MainLevel.tscn")

func _on_exit_pressed() -> void:
	LevelManager.reset()
	get_tree().change_scene_to_file("res://ui/menu.tscn")
