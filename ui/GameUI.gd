extends Control

@onready var end_turn_button: TextureButton = $CanvasLayer/HBoxContainer/EndTurnButton
@export var turn_label: Label

var max_turns: int

func _ready():
	print("GameUI: ready, connecting signals")
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	TurnManager.turn_ended.connect(_on_turn_ended)
	LevelManager.level_loaded.connect(_on_level_loaded)
	print("GameUI: connected to level_loaded")

func _on_level_loaded(turns: int):
	print("GameUI: level_loaded received, turns: ", turns)
	max_turns =  turns
	turn_label.text = "Turn 0/" + str(max_turns)

func _on_end_turn_pressed():
	TurnManager.end_turn()

func _on_turn_ended(turn_count : int):
	turn_label.text = "Turn " + str(turn_count) + "/" + str(max_turns)
