extends Node

enum Dir { NW, SW, SE, NE }

func get_tile_in_direction(tile: Vector2i, dir: Dir) -> Vector2i:
	# Uses your exact offset math, but with SW and SE correctly mapped for odd rows!
	if tile.y % 2 == 0:  # Even row
		match dir:
			Dir.NW: return tile + Vector2i(-1, -1)
			Dir.SW: return tile + Vector2i(-1, 1)
			Dir.SE: return tile + Vector2i(0, 1)
			Dir.NE: return tile + Vector2i(0, -1)
	else:  # Odd row
		match dir:
			Dir.NW: return tile + Vector2i(0, -1)
			Dir.SW: return tile + Vector2i(0, 1)   # Fixed! Was previously (1, 1)
			Dir.SE: return tile + Vector2i(1, 1)   # Fixed! Was previously (0, 1)
			Dir.NE: return tile + Vector2i(1, -1)
	return tile

func get_isometric_neighbors(tile: Vector2i) -> Array[Vector2i]:
	return [
		get_tile_in_direction(tile, Dir.NW),
		get_tile_in_direction(tile, Dir.SW),
		get_tile_in_direction(tile, Dir.SE),
		get_tile_in_direction(tile, Dir.NE)
	]

# Helper to figure out which direction the player clicked
func get_direction_to_neighbor(from_tile: Vector2i, to_tile: Vector2i):
	for d in Dir.values():
		if get_tile_in_direction(from_tile, d) == to_tile:
			return d
	return null

func can_move_to(to: Vector2i, floor_tilemap: TileMapLayer, wall_tilemap: TileMapLayer) -> bool:
	if floor_tilemap.get_cell_source_id(to) == -1:
		return false
	if wall_tilemap.get_cell_source_id(to) != -1:
		return false
		
	var tile_data: TileData = floor_tilemap.get_cell_tile_data(to)
	if tile_data != null:
		var floor_type: int = tile_data.get_custom_data("floor_type")
		if floor_type == 2:
			return false
	return true
