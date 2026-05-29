extends CharacterBody2D
class_name BasePlayer

var grid_pos : Vector2 = Vector2.ZERO 

#energy and movement stats template for now for wheelchair inheritance
var max_energy : int = 100
var current_energy : int = 100
var cost_per_tile : int = 10

#isometric size for now
const TILE_WIDTH = 500
const TILE_HEIGHT = 290

func _ready():
	#snap to the starting position
	position = grid_to_world(grid_pos)


#func detects both a mouse click and a mobile screen tap
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tap_position = get_global_mouse_position()
		var target_grid = world_to_grid(tap_position)
		
		#route the tap through energy check func
		attempt_move(target_grid) 

func _process(_delta):
	#godot arrow key actions
	if Input.is_action_just_pressed("ui_right"):
		attempt_move(grid_pos + Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_left"):
		attempt_move(grid_pos + Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_down"):
		attempt_move(grid_pos + Vector2(0, 1))
	elif Input.is_action_just_pressed("ui_up"):
		attempt_move(grid_pos + Vector2(0, -1))

#override this func later when integrating
func attempt_move(target_grid: Vector2):
	if current_energy < cost_per_tile:
		print("Not enough energy!")
		return
	
	#if safe, spend energy and move
	current_energy -= cost_per_tile
	grid_pos = target_grid
	position = grid_to_world(grid_pos)

#convert pixels to grid
func world_to_grid(screen_pos: Vector2) -> Vector2:
	var half_w = TILE_WIDTH / 2.0
	var half_h = TILE_HEIGHT / 2.0
	var calc_x = round((screen_pos.x / half_w + screen_pos.y / half_h) / 2.0)
	var calc_y = round((screen_pos.y / half_h - screen_pos.x / half_w) / 2.0)
	return Vector2(calc_x, calc_y)

#convert grid to pixels
func grid_to_world(grid_coords: Vector2) -> Vector2:
	var screen_x = (grid_coords.x - grid_coords.y) * (TILE_WIDTH / 2.0)
	var screen_y = (grid_coords.x + grid_coords.y) * (TILE_HEIGHT / 2.0)
	return Vector2(screen_x, screen_y)
