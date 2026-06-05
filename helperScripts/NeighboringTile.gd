extends Node

# GridUtils.gd or TurnManager.gd
const WALL_NW = 2
const WALL_NE = 1
const WALL_SE = 4
const WALL_SW = 8


func get_isometric_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	if tile.y % 2 == 0:  # Even row
		neighbors = [
			tile + Vector2i(-1, -1),  # NW
			tile + Vector2i(-1,  1),  # SW
			tile + Vector2i( 0,  1),  # SE
			tile + Vector2i( 0, -1),  # NE
		]
	else:  # Odd row
		neighbors = [
			tile + Vector2i( 0, -1),  # NW
			tile + Vector2i( 0,  1),  # SE
			tile + Vector2i( 1,  1),  # SW
			tile + Vector2i( 1, -1),  # NE
		]
	return neighbors

func can_move_to(from: Vector2i, to: Vector2i, floor_tilemap: TileMapLayer, wall_tilemap: TileMapLayer) -> bool:
	if floor_tilemap.get_cell_source_id(to) == -1:
		return false
	
	var delta = to - from
	var exit_blocked = is_wall_in_direction(from, delta, wall_tilemap)
	var entry_blocked = is_wall_in_direction(to, opposite(delta), wall_tilemap)

	if exit_blocked or entry_blocked:
		return false
	return true

func is_wall_in_direction(tile: Vector2i, delta: Vector2i, wall_tilemap: TileMapLayer) -> bool:
	var tile_data = wall_tilemap.get_cell_tile_data(tile)

	if tile_data == null:
		return false
	var walls: int = tile_data.get_custom_data("blocked_directions")
	var direction_map: Dictionary
	if tile.y % 2 == 0:  # Even row
		direction_map = {
			Vector2i(-1, -1): WALL_NW,
			Vector2i(-1,  1): WALL_SW,
			Vector2i( 0,  1): WALL_SE,
			Vector2i( 0, -1): WALL_NE,
		}
	else:  # Odd row
		direction_map = {
			Vector2i( 0, -1): WALL_NW,
			Vector2i( 0,  1): WALL_SE,
			Vector2i( 1,  1): WALL_SW,
			Vector2i( 1, -1): WALL_NE,
		}
	
	if delta in direction_map:
		return walls & direction_map[delta]
	return false

func opposite(delta: Vector2i) -> Vector2i:
	return Vector2i(-delta.x, -delta.y)
