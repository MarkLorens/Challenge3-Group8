extends Node

signal turn_ended(turn_count: int)
signal active_player_changed(player: BasePlayer)

var turn_count: int = 0
var active_player: BasePlayer = null
var players: Array[BasePlayer] = []

func register_player(player: BasePlayer) -> void:
	players.append(player)
	
	if active_player == null:
		active_player = player
		active_player_changed.emit(active_player)

func end_turn() -> void:
	turn_count += 1
	turn_ended.emit(turn_count)
	
	var next_index = (players.find(active_player) + 1) % players.size()
	active_player = players[next_index]
	active_player_changed.emit(active_player)
	turn_ended.emit(turn_count)
