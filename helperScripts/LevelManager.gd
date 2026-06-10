extends Node

signal level_loaded(max_turns: int)
signal objective_reached(poi_id: String, description: String)
signal objective_completed(poi_id: String, description: String)

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
				"Main":  "Attend meeting 
				within 20 turns",
				"Side1": "Get Coffee",
				"Side2": "Help Colleague B"
			}
	return {}

func objective_tile_reached(poi_id: String) -> void:
	var objectives = get_objectives()
	if poi_id in objectives and not poi_id in completed_objectives:
		objective_reached.emit(poi_id, objectives[poi_id])

func complete_objective(poi_id: String) -> void:
	var objectives = get_objectives()
	if poi_id in objectives and not poi_id in completed_objectives:
		completed_objectives[poi_id] = true
		objective_completed.emit(poi_id, objectives[poi_id])
