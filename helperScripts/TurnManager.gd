extends Node

signal turn_ended

func end_turn():
	turn_ended.emit()
