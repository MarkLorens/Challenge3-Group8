extends CharacterBody2D
class_name BasePlayer
#Grid-By-Grid movement
@export var floor_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer
@export var highlight_layer: TileMapLayer
@export var max_move_points: int = 2
var current_move_points: int

var target_pos: Vector2 = global_position
var is_moving: bool = false
var current_grid: Vector2i

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

func _ready() -> void:
	current_grid = floor_tilemap.local_to_map(floor_tilemap.to_local(global_position))
	current_move_points = max_move_points

	highlight_layer.show_move_range(
		current_grid,
		current_move_points
	)
	
func _unhandled_input(event):
	if is_moving:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			var clicked_tile = floor_tilemap.local_to_map(
				floor_tilemap.to_local(mouse_pos)
			)

			var valid_neighbors = get_isometric_neighbors(current_grid)
			if clicked_tile not in valid_neighbors:
				return

			if can_move_to(clicked_tile):
				current_grid = clicked_tile
				global_position = floor_tilemap.to_global(
					floor_tilemap.map_to_local(current_grid)
				)
				current_move_points -= 1
				if current_move_points > 0:
					highlight_layer.show_move_range(
						current_grid,
						current_move_points
					)
				else:
					highlight_layer.clear()
				print(current_grid)

#func get_reachable_tiles(start: Vector2i, max_steps: int) -> Array[Vector2i]:
	

func can_move_to(tile: Vector2i) -> bool:

	if floor_tilemap.get_cell_source_id(tile) == -1:
		return false
	if wall_tilemap.get_cell_source_id(tile) != -1:
		return false

	return true
