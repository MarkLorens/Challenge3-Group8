extends "res://entities/player/base_player.gd"

class_name WheelchairPlayer

func _ready():
	max_energy = 80
	current_energy = 80
	cost_per_tile = 10 
	
	# call BasePlayer's ready function
	super._ready()

#override base movement to check for energy n obstacles
func attempt_move(target_grid: Vector2):
	# 1. Check if we have enough energy
	if current_energy < cost_per_tile:
		print("Not enough energy!")
		return
		
	# 2.check if the tile is an obstacle
	# if map.is_obstacle(target_grid):
	#     print("Cannot pass!")
	#     return
		
	# 3.if not, spend energy and move
	current_energy -= cost_per_tile
	grid_pos = target_grid
	position = grid_to_world(grid_pos)
