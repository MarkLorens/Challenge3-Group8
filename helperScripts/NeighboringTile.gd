extends Node


func get_isometric_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	if tile.y % 2 == 0:  # Even row
		neighbors = [
			tile + Vector2i(0, -1),   # NE
			tile + Vector2i(-1, -1),  # NW
			tile + Vector2i(0, 1),    # SE
			tile + Vector2i(-1, 1),   # SW
		]
	else:  # Odd row
		neighbors = [
			tile + Vector2i(1, -1),   # NE
			tile + Vector2i(0, -1),   # NW
			tile + Vector2i(1, 1),    # SE
			tile + Vector2i(0, 1),    # SW
		]
	return neighbors
