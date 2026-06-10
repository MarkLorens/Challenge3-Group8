extends CharacterBody2D
class_name BasePlayer

# Grid-By-Grid movement
@export var floor_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer
@export var highlight_layer: TileMapLayer
@export var poi_tilemap: TileMapLayer
@export var max_move_points: int = 6
@export var max_move_distance: int = 1

@onready var sprite = $Sprite2D

var _map_floor: int = 1

@export var map_floor: int:
	set(value):
		_map_floor = value
		# Guard against calling check_floor before exports are assigned
		if floor_tilemap != null:
			check_floor()
	get:
		return _map_floor

var current_move_points: int
var target_pos: Vector2 = global_position
var is_moving: bool = false
var current_grid: Vector2i
var movement_locked: bool
var wall_tilemap_floor: TileMapLayer
var floor_tilemap_floor: TileMapLayer
var poi_tilemap_floor: TileMapLayer

signal move_updated(current: int, max: int)
signal stairs_available(can_use: bool)
signal left_objective_tile

func check_stairs() -> void:
	stairs_available.emit(
		current_grid == Vector2i(0, -5)
		or current_grid == Vector2i(1, -9)
	)

func check_floor() -> void:
	if map_floor == 2:
		floor_tilemap_floor = floor_tilemap.get_node("FloorTileSecondFloor") as TileMapLayer
		wall_tilemap_floor = wall_tilemap.get_node("WallTileSecondFloor") as TileMapLayer
		poi_tilemap_floor = poi_tilemap
	else:
		floor_tilemap_floor = floor_tilemap
		wall_tilemap_floor = wall_tilemap
		poi_tilemap_floor = poi_tilemap
func _ready() -> void:
	add_to_group("player")
	current_move_points = max_move_points

	TurnManager.turn_ended.connect(end_turn)

	check_floor()
	if SaveManager.has_save():
		var saved_grid = SaveManager.load_position()

		if saved_grid != Vector2i(-1, -1):
			current_grid = saved_grid

			global_position = floor_tilemap_floor.to_global(
				floor_tilemap_floor.map_to_local(current_grid)
			)

			SaveManager.delete_save()
	else:
		current_grid = floor_tilemap_floor.local_to_map(
			floor_tilemap_floor.to_local(global_position)
		)
	check_stairs()

	await get_tree().process_frame

	highlight_layer.show_move_range(
		current_grid,
		max_move_distance
	)

	move_updated.emit(
		current_move_points,
		max_move_points
	)

func _unhandled_input(event):
	if is_moving or current_move_points <= 0:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var clicked_tile = floor_tilemap_floor.local_to_map(floor_tilemap_floor.to_local(mouse_pos))
		var push_dir = NeighboringTile.get_direction_to_neighbor(current_grid, clicked_tile)
		if push_dir != null:
			var pushable_obj = get_pushable_at(clicked_tile)
			
			if pushable_obj:
				var target_push_tile = NeighboringTile.get_tile_in_direction(clicked_tile, push_dir)
				if NeighboringTile.can_move_to(target_push_tile, floor_tilemap_floor, wall_tilemap_floor) and get_pushable_at(target_push_tile) == null:
					pushable_obj.push_to(target_push_tile)
					current_move_points -= 1
					move_updated.emit(current_move_points, max_move_points)
					# current_grid = clicked_tile
					# global_position = floor_tilemap_floor.to_global(floor_tilemap_floor.map_to_local(current_grid))
					
			else:
				if NeighboringTile.can_move_to(clicked_tile, floor_tilemap_floor, wall_tilemap_floor):
					current_grid = clicked_tile
					global_position = floor_tilemap_floor.to_global(floor_tilemap_floor.map_to_local(current_grid))
					current_move_points -= 1
					check_tile_effects()
					check_stairs()
					move_updated.emit(current_move_points, max_move_points)
					
			if current_move_points > 0:
				highlight_layer.show_move_range(current_grid, max_move_distance)
			else:
				highlight_layer.clear()

func get_pushable_at(grid_pos: Vector2i) -> Pushable:
	var pushables = get_tree().get_nodes_in_group("pushable")
	for p in pushables:
		if p.current_grid == grid_pos:
			return p # This is the line that was previously indented incorrectly!
	return null
	
func end_turn(_turn_count: int):
	current_move_points = max_move_points
	move_updated.emit(current_move_points, max_move_points)  
	highlight_layer.show_move_range(current_grid, max_move_distance)

func _on_end_turn_button_pressed() -> void:
	pass

# Floor Checks
func check_tile_effects() -> void:
	_apply_floor_effects()
	check_poi()

func _apply_floor_effects() -> void:
	var extra_z = map_floor - 1
	var tile_data: TileData = floor_tilemap_floor.get_cell_tile_data(current_grid)
	if tile_data == null:
		return
	
	var floor_type: int = tile_data.get_custom_data("floor_type")
	
	match floor_type:
		1:
			z_index = 0
			movement_locked = false
		2:
			movement_locked = true
			highlight_layer.clear()
		3:
			z_index = 2
			movement_locked = false
		4:
			z_index = 1
			movement_locked = false
		_:
			z_index = 0
			movement_locked = false

func check_poi() -> void:
	if poi_tilemap_floor.get_cell_source_id(current_grid) != -1:
		var poi_data = poi_tilemap_floor.get_cell_tile_data(current_grid)
		var poi_id: String = poi_data.get_custom_data("poi_id")
		var _poi_interaction: String = poi_data.get_custom_data("poi_interaction")
		LevelManager.objective_tile_reached(poi_id)
	else:
		left_objective_tile.emit()   
