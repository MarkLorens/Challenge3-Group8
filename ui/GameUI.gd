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
@onready var character_portrait = $CanvasLayer/TurnLabelBg/CharacterPortrait
@export var move_label: Label

var tex_portrait_abbie = preload("res://assets/art/characters/Player_Resized.png")
var tex_portrait_will = preload("res://assets/art/characters/Player_Wheelchair_Resized.png")
var stairs_available := false

var tex_act_enabled = preload("res://assets/art/button/ActButton.png")
var tex_act_disabled = preload("res://assets/art/button/ActDisabledButton.png")
var tex_move_enabled = preload("res://assets/art/button/MoveButton.png")
var tex_move_disabled = preload("res://assets/art/button/MoveDisabledButton.png")
var tex_switch_will = preload("res://assets/art/button/WillSwitch.png")
var tex_switch_will_disabled = preload("res://assets/art/button/WillSwitchDisabled.png")
var tex_switch_abbie = preload("res://assets/art/button/AbbieSwitch.png")
var tex_switch_abbie_disabled = preload("res://assets/art/button/AbbieSwitchDisabled.png")

var tex_objective_complete = preload("res://assets/art/ui/ObjectiveComplete.png")
var tex_collapsed = preload("res://assets/art/ui/missionboardcrop.png")
var tex_expanded = preload("res://assets/art/ui/MissionBoard.png")

var current_poi_id: String = ""
var max_turns: int
var objective_checkboxes: Dictionary = {}

var objective_popup: Control = null

func _ready():
	if not TurnManager.turn_ended.is_connected(_on_turn_ended):
		TurnManager.turn_ended.connect(_on_turn_ended)
	if not TurnManager.active_player_changed.is_connected(_on_active_player_changed):
		TurnManager.active_player_changed.connect(_on_active_player_changed)
	if not LevelManager.level_loaded.is_connected(_on_level_loaded):
		LevelManager.level_loaded.connect(_on_level_loaded)
	if not LevelManager.objective_reached.is_connected(_on_reaching_objective_tile):
		LevelManager.objective_reached.connect(_on_reaching_objective_tile)
	if not LevelManager.objective_completed.is_connected(_on_objective_completed):
		LevelManager.objective_completed.connect(_on_objective_completed)
	if not LevelManager.main_objective_completed.is_connected(_on_main_objective_completed):
		LevelManager.main_objective_completed.connect(_on_main_objective_completed)

	if not end_turn_button.pressed.is_connected(_on_end_turn_pressed):
		end_turn_button.pressed.connect(_on_end_turn_pressed)
	if not action_button.pressed.is_connected(_complete_objective):
		action_button.pressed.connect(_complete_objective)
	if not move_button.pressed.is_connected(_on_move_button_pressed):
		move_button.pressed.connect(_on_move_button_pressed)
	if not mission_board.pressed.is_connected(_on_mission_board_pressed):
		mission_board.pressed.connect(_on_mission_board_pressed)
	if not close_area.pressed.is_connected(_on_mission_board_pressed):
		close_area.pressed.connect(_on_mission_board_pressed)

	mission_details.visible = false
	_set_act_button_state(false)

	await get_tree().process_frame

	_connect_active_player_signals()
	_update_move_button_to_switch()
	if TurnManager.active_player:
		_update_character_portrait(TurnManager.active_player)
		var p = TurnManager.active_player
		move_label.text = "MOVE " + str(p.max_move_points - p.current_move_points) + "/" + str(p.max_move_points)

func _on_move_button_pressed() -> void:
	TurnManager.switch_player()

func _update_move_button_to_switch() -> void:
	var players = get_tree().get_nodes_in_group("player")
	var active = TurnManager.active_player
	var other_player = null
	for p in players:
		if p != active:
			other_player = p
			break
	if other_player == null:
		move_button.disabled = true
		move_button.texture_normal = tex_move_disabled
		return
	if "PlayerWheelChair" in other_player.name:
		move_button.texture_normal = tex_switch_will
		move_button.texture_disabled = tex_switch_will_disabled
	else:
		move_button.texture_normal = tex_switch_abbie
		move_button.texture_disabled = tex_switch_abbie_disabled
	move_button.disabled = false



func _set_act_button_state(is_enabled: bool) -> void:
	action_button.disabled = !is_enabled
	action_button.texture_normal = tex_act_enabled if is_enabled else tex_act_disabled

func _on_stairs_available(can_use: bool) -> void:
	stairs_available = can_use
	if can_use:
		var player = TurnManager.active_player
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

func _on_reaching_objective_tile(poi_id: String, description: String):
	current_poi_id = poi_id
	action_label.text = description
	action_button.show()
	_set_act_button_state(true)

func _complete_objective():
	if stairs_available:
		var player = TurnManager.active_player
		if player:
			if player.current_grid == Vector2i(1, -9):
				player.current_grid = Vector2i(0, -5)
				player.z_index = 2
				player.map_floor = 1
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
		var completing_id = current_poi_id
		LevelManager.complete_objective(completing_id)
		action_label.text = ""
		current_poi_id = ""
		_set_act_button_state(false)

func _on_objective_completed(poi_id: String, _description: String) -> void:
	if poi_id in objective_checkboxes:
		objective_checkboxes[poi_id].button_pressed = true
	
	if poi_id != "Main":
		_show_objective_popup()

func _show_objective_popup() -> void:
	if objective_popup != null:
		objective_popup.queue_free()
		objective_popup = null

	var canvas = $CanvasLayer

	var popup = Control.new()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.z_index = 100
	canvas.add_child(popup)
	objective_popup = popup

	var img = TextureRect.new()
	img.texture = tex_objective_complete
	img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.custom_minimum_size = Vector2(400, 200)
	img.position = Vector2(-200, -100)
	popup.add_child(img)

	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(func():
		if is_instance_valid(popup):
			popup.queue_free()
			objective_popup = null
	)


func _on_main_objective_completed() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://ui/MissionSuccess.tscn")



func _connect_active_player_signals() -> void:
	for p in get_tree().get_nodes_in_group("player"):
		if p.move_updated.is_connected(_on_move_updated):
			p.move_updated.disconnect(_on_move_updated)
		if p.left_objective_tile.is_connected(_on_left_objective_tile):
			p.left_objective_tile.disconnect(_on_left_objective_tile)
		if p.stairs_available.is_connected(_on_stairs_available):
			p.stairs_available.disconnect(_on_stairs_available)
	var active = TurnManager.active_player
	if active:
		active.move_updated.connect(_on_move_updated)
		active.left_objective_tile.connect(_on_left_objective_tile)
		active.stairs_available.connect(_on_stairs_available)

func _on_active_player_changed(player: BasePlayer) -> void:
	_connect_active_player_signals()
	move_label.text = "MOVE " + str(player.max_move_points - player.current_move_points) + "/" + str(player.max_move_points)
	current_poi_id = ""
	action_label.text = ""
	_set_act_button_state(false)
	_update_move_button_to_switch()
	var camera = player.get_node_or_null("Camera")
	if camera:
		camera.make_current()
	_update_character_portrait(player)

func _update_character_portrait(player) -> void:
	if character_portrait == null:
		return
	if "PlayerWheelChair" in player.name:
		character_portrait.texture = tex_portrait_will
	else:
		character_portrait.texture = tex_portrait_abbie

func _on_move_updated(current: int, max: int) -> void:
	move_label.text = "MOVE " + str(max - current) + "/" + str(max)


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
