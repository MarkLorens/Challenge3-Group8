extends TileMapLayer

@export var floor_tilemap: TileMapLayer

func show_move_range(center: Vector2i, move_range: int):

	clear()

	for x in range(-move_range, move_range + 1):
		for y in range(-move_range, move_range + 1):
			
			if x == 0 and y == 0:
				continue

			var tile = center + Vector2i(x, y)

			var distance = abs(x) + abs(y)

			if distance > move_range:
				continue

			if floor_tilemap.get_cell_source_id(tile) == -1:
				continue

			set_cell(tile, 0, Vector2i.ZERO)
