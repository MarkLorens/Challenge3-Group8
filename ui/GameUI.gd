extends Control

@export var turn_label: Label
@export var action_label: Label
@onready var end_turn_button: TextureButton = $CanvasLayer/EndTurnButton
@onready var mission_board = $CanvasLayer/MissionBoard
@onready var mission_details = $CanvasLayer/MissionDetail
@onready var mission_bg = $CanvasLayer/MissionDetail/TextureRect
@onready var close_area = $CanvasLayer/MissionDetail/CloseArea
@onready var action_button = $CanvasLayer/ActionButton
@onready var move_button = $CanvasLayer/MoveButton
@onready var mission_list = $CanvasLayer/MissionDetail/MissionDetail
@onready var change_player_button = $CanvasLayer/ChangePlayerButton
@export var move_label: Label

var stairs_available := false

var tex_act_enabled = preload("res://assets/art/button/ActButton.png")
var tex_act_disabled = preload("res://assets/art/button/ActDisabledButton.png")
var tex_move_enabled = preload("res://assets/art/button/MoveButton.png")
var tex_move_disabled = preload("res://assets/art/button/MoveDisabledButton.png")

var current_poi_id: String = ""
var max_turns: int

var tex_collapsed = preload("res://assets/art/ui/missionboardcrop.png")
var tex_expanded = preload("res://assets/art/ui/MissionBoard.png")

var objective_checkboxes: Dictionary = {}

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	TurnManager.turn_ended.connect(_on_turn_ended)
	LevelManager.level_loaded.connect(_on_level_loaded)
	LevelManager.objective_reached.connect(_on_reaching_objective_tile)
	LevelManager.objective_completed.connect(_on_objective_completed)

	action_button.pressed.connect(_complete_objective)

	mission_details.visible = false

	if not mission_board.pressed.is_connected(_on_mission_board_pressed):
		mission_board.pressed.connect(_on_mission_board_pressed)

	close_area.pressed.connect(_on_mission_board_pressed)

	_set_act_button_state(false)
	_set_move_button_state(false)

	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.move_updated.connect(_on_move_updated)
		player.left_objective_tile.connect(_on_left_objective_tile)
		player.stairs_available.connect(_on_stairs_available)

func _on_stairs_available(can_use: bool) -> void:
	stairs_available = can_use

	if can_use:
		var player = get_tree().get_first_node_in_group("player")

		if player and player.current_grid == Vector2i(1, -9):
			action_label.text = "Go Downstairs"
		else:
			action_label.text = "Go Upstairs"

		_set_act_button_state(true)
	else:
		if current_poi_id == "":
			action_label.text = ""
			_set_act_button_state(false)

func _on_left_objective_tile() -> void:
	current_poi_id = ""
	action_label.text = ""
	_set_act_button_state(false)

func _set_act_button_state(is_enabled: bool) -> void:
	action_button.disabled = !is_enabled

	if is_enabled:
		action_button.texture_normal = tex_act_enabled
	else:
		action_button.texture_normal = tex_act_disabled

func _set_move_button_state(is_enabled: bool) -> void:
	move_button.disabled = !is_enabled

	if is_enabled:
		move_button.texture_normal = tex_move_enabled
	else:
		move_button.texture_normal = tex_move_disabled

func _build_mission_list() -> void:
	for child in mission_list.get_children():
		child.queue_free()

	objective_checkboxes.clear()

	var objectives = LevelManager.get_objectives()

	for poi_id in objectives:
		var cb = CheckBox.new()

		cb.text = objectives[poi_id]
		cb.disabled = true
		cb.button_pressed = poi_id in LevelManager.completed_objectives

		cb.add_theme_color_override("font_color", Color(0.2, 0.2, 0.4))
		cb.add_theme_color_override("font_disabled_color", Color(0.2, 0.2, 0.4))

		mission_list.add_child(cb)
		objective_checkboxes[poi_id] = cb

func _on_objective_completed(poi_id: String, _description: String) -> void:
	if poi_id in objective_checkboxes:
		objective_checkboxes[poi_id].button_pressed = true

func _on_move_updated(current: int, max: int) -> void:
	move_label.text = "MOVE " + str(max - current) + "/" + str(max)
	_set_move_button_state(current > 0)

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
	max_turns = turns
	turn_label.text = "Turn 0/" + str(max_turns)
	_build_mission_list()

func _on_end_turn_pressed():
	TurnManager.end_turn()

func _on_turn_ended(turn_count: int):
	turn_label.text = "Turn " + str(turn_count) + "/" + str(max_turns)
	_set_move_button_state(true)

func _on_reaching_objective_tile(poi_id: String, description: String):
	current_poi_id = poi_id
	action_label.text = description
	action_button.show()
	_set_act_button_state(true)

func _complete_objective():

	if stairs_available:
		var player = get_tree().get_first_node_in_group("player")

		if player:

			# Upstairs -> Downstairs
			if player.current_grid == Vector2i(1, -9):
				player.current_grid = Vector2i(0, -5)
				player.z_index = 2
				player.map_floor = 1

			# Downstairs -> Upstairs
			else:
				player.current_grid = Vector2i(1, -9)
				player.z_index = 1
				player.map_floor = 2
			
			player.check_floor()
			player.global_position = player.floor_tilemap.to_global(
				player.floor_tilemap.map_to_local(player.current_grid)
			)

			player.highlight_layer.show_move_range(
				player.current_grid,
				player.max_move_distance
			)

			player.check_stairs()

		return

	if current_poi_id != "":
		LevelManager.complete_objective(current_poi_id)

		action_label.text = ""
		current_poi_id = ""

		_set_act_button_state(false)
