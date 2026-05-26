extends CharacterBody2D
class_name BasePlayer

var grid_pos : Vector2 = Vector2.ZERO 

#isometric diamond size
const TILE_WIDTH = 500
const TILE_HEIGHT = 290

func _ready():
	#snap to the starting position immediately
	position = grid_to_world(grid_pos)

func _process(_delta):
	#godot arrow key actions (for now)
	if Input.is_action_just_pressed("ui_right"):
		move_to_grid(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_left"):
		move_to_grid(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_down"):
		move_to_grid(Vector2(0, 1))
	elif Input.is_action_just_pressed("ui_up"):
		move_to_grid(Vector2(0, -1))

func move_to_grid(direction: Vector2):
	grid_pos += direction
	
	var target_screen_pos = grid_to_world(grid_pos)
	
	position = target_screen_pos

#converts cartesian (0,1) to isometric screen coordinates
func grid_to_world(grid_coords: Vector2) -> Vector2:
	var screen_x = (grid_coords.x - grid_coords.y) * (TILE_WIDTH / 2.0)
	var screen_y = (grid_coords.x + grid_coords.y) * (TILE_HEIGHT / 2.0)
	return Vector2(screen_x, screen_y)
