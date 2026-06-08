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

func can_move_to(to: Vector2i, floor_tilemap: TileMapLayer, wall_tilemap: TileMapLayer) -> bool:
	if floor_tilemap.get_cell_source_id(to) == -1:
		return false
	if wall_tilemap.get_cell_source_id(to) != -1:
		return false
	return true
