extends Node2D

var is_open = false

# @export makes this show up in the Inspector on the right!
# Vector2(64, 32) is a standard isometric diagonal movement (down-right).
@export var slide_offset: Vector2 = Vector2(0,0)

func _on_interactable_area_body_entered(body):
	if body.name == "BasePlayer":
		open_door()
		$StaticBody2D.z_index = 2

func _on_interactable_area_body_exited(body):
	if body.name == "BasePlayer":
		close_door()
		$StaticBody2D.z_index = 0

func open_door():
	if is_open: return
	is_open = true
	
	# Safely turn off the collision shape
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property($StaticBody2D, "position", slide_offset, 0.3)

func close_door():
	if not is_open: return
	is_open = false
	
	# Safely turn the collision shape back on
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	
	var tween = create_tween()
	tween.tween_property($StaticBody2D, "position", Vector2.ZERO, 0.3)
