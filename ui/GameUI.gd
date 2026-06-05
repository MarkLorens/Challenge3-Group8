extends Control
@onready var end_turn_button: TextureButton = $CanvasLayer/EndTurnButton
@export var turn_label: Label
@onready var mission_board = $CanvasLayer/MissionBoard
@onready var mission_details = $CanvasLayer/MissionDetail
@onready var mission_bg = $CanvasLayer/MissionDetail/TextureRect
@onready var close_area = $CanvasLayer/MissionDetail/CloseArea  
var max_turns: int
var tex_collapsed = preload("res://assets/art/ui/missionboardcrop.png")
var tex_expanded = preload("res://assets/art/ui/MissionBoard.png")

func _ready():
	print("GameUI: ready, connecting signals")
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	TurnManager.turn_ended.connect(_on_turn_ended)
	LevelManager.level_loaded.connect(_on_level_loaded)
	print("GameUI: connected to level_loaded")
	mission_details.visible = false
	if not mission_board.pressed.is_connected(_on_mission_board_pressed):
		mission_board.pressed.connect(_on_mission_board_pressed)
	close_area.pressed.connect(_on_mission_board_pressed)  

func _on_mission_board_pressed() -> void:
	var is_open = !mission_details.visible
	mission_details.visible = is_open
	if is_open:
		mission_bg.texture = tex_expanded
		mission_board.texture_normal = null
	else:
		mission_bg.texture = tex_collapsed
		mission_board.texture_normal = tex_collapsed

func _on_level_loaded(turns: int):
	print("GameUI: level_loaded received, turns: ", turns)
	max_turns = turns
	turn_label.text = "Turn 0/" + str(max_turns)

func _on_end_turn_pressed():
	TurnManager.end_turn()

func _on_turn_ended(turn_count: int):
	turn_label.text = "Turn " + str(turn_count) + "/" + str(max_turns)
