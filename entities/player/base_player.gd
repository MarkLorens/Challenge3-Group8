extends CharacterBody2D
class_name BasePlayer
#Grid-By-Grid movement
@export var floor_tilemap: TileMapLayer
@export var speed: float = 400.0

var target_pos: Vector2 = global_position
var is_moving: bool = false
var current_grid: Vector2i

func _ready() -> void:
	current_grid = floor_tilemap.local_to_map(global_position)
	global_position = floor_tilemap.map_to_local(current_grid)

	target_pos = global_position
	print(current_grid)
	print(floor_tilemap.map_to_local(Vector2i(0,0)))
	
func _unhandled_input(event):

	if is_moving:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()

			var clicked_tile = floor_tilemap.local_to_map(
				floor_tilemap.to_local(mouse_pos)
			)
			current_grid = clicked_tile
			global_position = floor_tilemap.map_to_local(current_grid)
			print(clicked_tile)

func move_grid(direction: Vector2i):

	current_grid += direction

	global_position = floor_tilemap.map_to_local(current_grid)

	print(current_grid)

func _draw():
	draw_circle(
		floor_tilemap.map_to_local(current_grid),
		5,
		Color.RED
	)
