extends Node2D
class_name Pushable

var current_grid: Vector2i
@export var floor_tilemap: TileMapLayer

func _ready() -> void:
	add_to_group("pushable")
	# Snap to grid on start based on physical position
	if floor_tilemap:
		current_grid = floor_tilemap.local_to_map(floor_tilemap.to_local(global_position))
		snap_to_grid()

func push_to(new_grid: Vector2i) -> void:
	current_grid = new_grid
	snap_to_grid()
	
	# TIP: If you want smooth sliding instead of teleporting, 
	# you can replace snap_to_grid() above with a Tween here!

func snap_to_grid() -> void:
	global_position = floor_tilemap.to_global(floor_tilemap.map_to_local(current_grid))
