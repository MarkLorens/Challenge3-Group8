extends Node

signal level_loaded(max_turns: int)
signal objective_reached(poi_id: String, description: String)
signal objective_completed(poi_id: String, description: String)
signal main_objective_completed()
signal all_side_objectives_completed()

var current_level: int = 0
var completed_objectives: Dictionary = {}

func reset() -> void:
	completed_objectives.clear() 

func load_level(level: int):
	current_level = level
	call_deferred("emit_signal", "level_loaded", get_max_turns())

func get_max_turns() -> int:
	match current_level:
		0:
			return 15
		1:
			return 12
	return 0

func get_objectives() -> Dictionary:
	match current_level:
		0:
			return {
				"Main":  "Attend meeting",
				"Side1": "Get Coffee",
				"Side2": "Collect Paper"
			}
	return {}

func get_side_objectives() -> Array:
	var all = get_objectives()
	var sides = []
	for key in all:
		if key != "Main":
			sides.append(key)
	return sides

func count_completed_side_objectives() -> int:
	var count = 0
	for key in get_side_objectives():
		if key in completed_objectives:
			count += 1
	return count

func objective_tile_reached(poi_id: String) -> void:
	var objectives = get_objectives()
	if poi_id in objectives and not poi_id in completed_objectives:
		objective_reached.emit(poi_id, objectives[poi_id])

func complete_objective(poi_id: String) -> void:
	var objectives = get_objectives()
	if poi_id in objectives and not poi_id in completed_objectives:
		completed_objectives[poi_id] = true
		objective_completed.emit(poi_id, objectives[poi_id])
		
		if poi_id == "Main":
			main_objective_completed.emit()
