extends CharacterBody2D
class_name BasePlayer
#Grid-By-Grid movement
@export var floor_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer
@export var highlight_layer: TileMapLayer
@export var move_range: int = 2

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
	current_grid = floor_tilemap.local_to_map(global_position)
	global_position = floor_tilemap.map_to_local(current_grid)

	target_pos = global_position
	
	highlight_layer.show_move_range(
		current_grid,
		move_range
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
			
			var distance = (
				abs(clicked_tile.x - current_grid.x)
				+ abs(clicked_tile.y - current_grid.y)
			)

			if distance > move_range:
				return
		
			if can_move_to(clicked_tile):
				current_grid = clicked_tile
				global_position = floor_tilemap.to_global(
					floor_tilemap.map_to_local(current_grid)
				)
				highlight_layer.show_move_range(
					current_grid,
					move_range
				)
				print(current_grid)
			

#func get_reachable_tiles(start: Vector2i, max_steps: int) -> Array[Vector2i]:
	

func can_move_to(tile: Vector2i) -> bool:

	if floor_tilemap.get_cell_source_id(tile) == -1:
		return false
	if wall_tilemap.get_cell_source_id(tile) != -1:
		return false

	return true
