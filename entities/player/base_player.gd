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
#
## Grid position (logical movement)
#var grid_pos: Vector2 = Vector2.ZERO
#
## Isometric tile size
#const TILE_WIDTH = 128
#const TILE_HEIGHT = 64
#
## Collision shape used for prediction
#var collision_shape: CircleShape2D
#
#func _ready():
	## Create small collision check shape
	#collision_shape = CircleShape2D.new()
	#collision_shape.radius = 1.0
#
	## Snap to start position
	#position = grid_to_world(grid_pos)
#
#
#func _process(_delta):
	#if Input.is_action_just_pressed("ui_right"):
		#try_move(Vector2(1, 0))
	#elif Input.is_action_just_pressed("ui_left"):
		#try_move(Vector2(-1, 0))
	#elif Input.is_action_just_pressed("ui_down"):
		#try_move(Vector2(0, 1))
	#elif Input.is_action_just_pressed("ui_up"):
		#try_move(Vector2(0, -1))
#
#
## ----------------------------
## GRID + PHYSICS CHECK
## ----------------------------
#func try_move(direction: Vector2):
#
	#var new_grid_pos = grid_pos + direction
	#var target_world_pos = grid_to_world(new_grid_pos)
#
	#var query = PhysicsShapeQueryParameters2D.new()
	#query.shape = collision_shape
	#query.transform = Transform2D(0, target_world_pos)
#
	#query.collide_with_bodies = true
	#query.collide_with_areas = true  
	#query.exclude = [self.get_rid()]
#
	#var result = get_world_2d().direct_space_state.intersect_shape(query)
#
	#if result.is_empty():
		#grid_pos = new_grid_pos
		#position = target_world_pos
	#else:
		#print("Blocked by:", result[0].collider.name)
#
#
## ----------------------------
## ISOMETRIC CONVERSION
## ----------------------------
#func grid_to_world(grid_coords: Vector2) -> Vector2:
	#var screen_x = (grid_coords.x - grid_coords.y) * (TILE_WIDTH / 2.0)
	#var screen_y = (grid_coords.x + grid_coords.y) * (TILE_HEIGHT / 2.0)
	#return Vector2(screen_x, screen_y)
