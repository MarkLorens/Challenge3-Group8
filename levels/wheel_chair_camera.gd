extends Camera2D

@export var min_zoom := 0.2
@export var max_zoom := 3.0
@export var pan_speed := 1.0

var touches := {}

func _unhandled_input(event):

	# -------------------------
	# TOUCH DOWN
	# -------------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

	# -------------------------
	# TOUCH MOVE
	# -------------------------
	elif event is InputEventScreenDrag:
		
		# update finger position
		touches[event.index] = event.position

		# -------------------------
		# 1 FINGER PAN
		# -------------------------
		if touches.size() == 1:
			position -= event.relative * pan_speed

		# -------------------------
		# 2 FINGER PINCH ZOOM
		# -------------------------
		elif touches.size() == 2:
			var points = touches.values()
			var p1 = points[0]
			var p2 = points[1]

			var current_distance = p1.distance_to(p2)

			# store previous distance safely using metadata
			if not has_meta("last_distance"):
				set_meta("last_distance", current_distance)
				return

			var last_distance = get_meta("last_distance")
			var diff = current_distance - last_distance

			zoom_camera(1.0 - diff * 0.005)

			set_meta("last_distance", current_distance)


func zoom_camera(factor: float):
	var new_zoom = zoom * factor

	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)

	zoom = new_zoom
