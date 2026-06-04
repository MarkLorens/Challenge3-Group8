extends Node

signal turn_ended(turn_count: int)

var turn_count: int = 0

func end_turn():
	turn_count += 1
	turn_ended.emit(turn_count)
