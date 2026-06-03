extends Control

@onready var end_turn_button: TextureButton = $CanvasLayer/EndTurnButton

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed():
	TurnManager.end_turn()
