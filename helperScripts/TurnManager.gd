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

func switch_player() -> void:
	_cleanup_freed_players()  
	if players.size() < 2:
		return
	var next_index = (players.find(active_player) + 1) % players.size()
	active_player = players[next_index]
	active_player_changed.emit(active_player)

func end_turn() -> void:
	_cleanup_freed_players()  # ← bersihkan dulu
	turn_count += 1
	turn_ended.emit(turn_count)
	for player in players:
		player.current_move_points = player.max_move_points
	if players.size() == 0:
		return
	var next_index = (players.find(active_player) + 1) % players.size()
	active_player = players[next_index]
	active_player_changed.emit(active_player)

func _cleanup_freed_players() -> void:
	players = players.filter(func(p): return is_instance_valid(p))
	if not is_instance_valid(active_player):
		active_player = players[0] if players.size() > 0 else null

func reset() -> void:
	turn_count = 0
	active_player = null
	players.clear()
