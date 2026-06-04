extends Node

signal level_loaded(max_turns: int)

var current_level: int = 0

func get_max_turns() -> int:
	match current_level:
		0:
			return 15
		1:
			return 12
	return 0

func load_level(level: int):
	current_level = level
	print("LevelManager: loading level ", level, " max turns: ", get_max_turns())
	call_deferred("emit_signal", "level_loaded", get_max_turns())
