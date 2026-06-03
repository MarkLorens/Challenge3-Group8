extends TileMapLayer

@export var floor_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer

func show_move_range(center: Vector2i, move_range: int):
	clear()
	
	var visited: Dictionary = {}
	var queue: Array = [[center, 0]]  # [tile, steps_used]
	visited[center] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var tile: Vector2i = current[0]
		var steps: int = current[1]
		
		if steps > 0:  # Don't highlight the player's own tile
			if floor_tilemap.get_cell_source_id(tile) != -1:
				if wall_tilemap.get_cell_source_id(tile) == -1:
					set_cell(tile, 0, Vector2i.ZERO)
		
		if steps >= move_range:
			continue
		
		for neighbor in NeighboringTile.get_isometric_neighbors(tile):
			if neighbor not in visited:
				visited[neighbor] = true
				queue.append([neighbor, steps + 1])
