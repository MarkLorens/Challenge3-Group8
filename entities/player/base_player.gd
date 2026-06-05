extends CharacterBody2D
class_name BasePlayer
#Grid-By-Grid movement
@export var floor_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer
@export var highlight_layer: TileMapLayer
@export var poi_tilemap: TileMapLayer
@export var max_move_points: int = 6  
@export var max_move_distance: int = 1
var current_move_points: int
var target_pos: Vector2 = global_position
var is_moving: bool = false
var current_grid: Vector2i

signal move_updated(current: int, max: int)  

func _ready() -> void:
	add_to_group("player")
	current_move_points = max_move_points
	TurnManager.turn_ended.connect(end_turn)
	
	if SaveManager.has_save():
		var saved_grid = SaveManager.load_position()
		if saved_grid != Vector2i(-1, -1):
			current_grid = saved_grid
			global_position = floor_tilemap.to_global(
				floor_tilemap.map_to_local(current_grid)
			)
			SaveManager.delete_save()
	else:
		current_grid = floor_tilemap.local_to_map(
			floor_tilemap.to_local(global_position)
		)
	
	await get_tree().process_frame
	highlight_layer.show_move_range(current_grid, max_move_distance)
	move_updated.emit(current_move_points, max_move_points)  

func _unhandled_input(event):
	if is_moving:
		return
	if current_move_points <= 0:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			var clicked_tile = floor_tilemap.local_to_map(
				floor_tilemap.to_local(mouse_pos)
			)
			var valid_neighbors = NeighboringTile.get_isometric_neighbors(current_grid)
			if clicked_tile not in valid_neighbors:
				return
			if NeighboringTile.can_move_to(current_grid, clicked_tile, floor_tilemap, wall_tilemap):
				current_grid = clicked_tile
				global_position = floor_tilemap.to_global(
					floor_tilemap.map_to_local(current_grid)
				)
				current_move_points -= 1
				check_poi()
				move_updated.emit(current_move_points, max_move_points)
				if current_move_points > 0:
					highlight_layer.show_move_range(current_grid, max_move_distance)
				else:
					highlight_layer.clear()

func end_turn(_turn_count: int):
	current_move_points = max_move_points
	move_updated.emit(current_move_points, max_move_points)  
	highlight_layer.show_move_range(current_grid, max_move_distance)

func _on_end_turn_button_pressed() -> void:
	pass

func check_poi() -> void:
	if poi_tilemap.get_cell_source_id(current_grid) != -1:
		var poi_data = poi_tilemap.get_cell_tile_data(current_grid)
		var poi_id: String = poi_data.get_custom_data("poi_id")
		var poi_interaction: String = poi_data.get_custom_data("poi_interaction")
		print(poi_interaction)
		LevelManager.objective_tile_reached(poi_id)
