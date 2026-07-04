extends Node

signal turn_ended(turn_count: int)
signal active_player_changed(player: BasePlayer)
signal restart_availability_changed(available: bool)
signal undo_availability_changed(available: bool)

# Restart is a puzzle safety-net, not a spam button: it may be used at most this
# many times per game session. The count only refills on a full game restart
# (reset_restart_uses(), called when MainLevel loads).
const MAX_RESTART_USES := 3

var turn_count: int = 0
var active_player: BasePlayer = null
var players: Array[BasePlayer] = []

# Snapshot of every player's state at the moment the current turn began.
# It is captured lazily on the first move of the turn, so it always reflects
# the positions before anyone acted this turn. player -> { grid, map_floor, z_index }
var turn_start_states: Dictionary = {}
var _snapshot_taken: bool = false
var restart_uses_remaining: int = MAX_RESTART_USES
var _restart_available: bool = false  # last value emitted via restart_availability_changed

# Ordered history of individual character moves made this turn, oldest first.
# Each entry stores the state the player had *before* that move so Undo can step
# a single move back: { player, grid, map_floor }. Cleared when the turn ends,
# on restart, and on level (re)load. Pushes are intentionally not recorded.
var move_history: Array = []
# Undo may only be pressed once per move: a move enables it, using it disables
# it again until the player moves. Tracked separately from move_history so the
# button stays disabled even while earlier moves remain on the stack.
var _undo_available: bool = false

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
	_cleanup_freed_players()
	if players.size() == 0:
		return
	turn_count += 1
	# A new turn is starting: forget the previous turn's snapshot and move
	# history so the next move captures fresh turn-start positions.
	_set_snapshot_taken(false)
	_clear_move_history()
	turn_ended.emit(turn_count)
	for player in players:
		player.current_move_points = player.max_move_points
	var next_index = (players.find(active_player) + 1) % players.size()
	active_player = players[next_index]
	active_player_changed.emit(active_player)

# Records where every player stands at the start of the current turn. Called on
# the first action of a turn; a no-op afterwards so it captures the turn's start.
func ensure_turn_snapshot() -> void:
	if _snapshot_taken:
		return
	turn_start_states.clear()
	for player in players:
		if is_instance_valid(player):
			turn_start_states[player] = {
				"grid": player.current_grid,
				"map_floor": player.map_floor,
				"z_index": player.z_index,
			}
	_set_snapshot_taken(true)

# Restores every player to the position and move points they had when the
# current turn began. Does nothing before the first move of a turn.
func restart_turn() -> void:
	if not _snapshot_taken or restart_uses_remaining <= 0:
		return
	for player in players:
		if is_instance_valid(player) and turn_start_states.has(player):
			player.reset_to_turn_start(turn_start_states[player])
	restart_uses_remaining -= 1
	_set_snapshot_taken(false)
	_clear_move_history()

# Records a single character move so Undo can step it back, and re-enables Undo.
# `grid`/`map_floor` are the player's state *before* the move was applied.
func record_move(player: BasePlayer, grid: Vector2i, map_floor: int) -> void:
	move_history.append({ "player": player, "grid": grid, "map_floor": map_floor })
	_set_undo_available(true)

# Steps the most recently moved character back one tile and refunds its move
# point. Control follows that character so the change is visible. Undo then stays
# disabled until the player moves again.
func undo_last_move() -> void:
	if not _undo_available or move_history.is_empty():
		return
	var entry = move_history.pop_back()
	var player = entry["player"]
	if is_instance_valid(player):
		if active_player != player:
			active_player = player
			active_player_changed.emit(player)
		player.undo_to(entry)
	_set_undo_available(false)

# True while Undo may be pressed (a move has been made since the last undo).
func can_undo() -> bool:
	return _undo_available

func _clear_move_history() -> void:
	move_history.clear()
	_set_undo_available(false)

func _set_undo_available(value: bool) -> void:
	if _undo_available == value:
		return
	_undo_available = value
	undo_availability_changed.emit(value)

# True when Restart may be pressed: a move has been made this turn and the
# session still has restart uses left.
func can_restart() -> bool:
	return _snapshot_taken and restart_uses_remaining > 0

# Refills the per-session restart allowance. Called on a full game restart, i.e.
# whenever MainLevel loads, since this autoload persists across scene reloads.
func reset_restart_uses() -> void:
	restart_uses_remaining = MAX_RESTART_USES
	_refresh_restart_availability()

# Drops any stored turn-start snapshot. Called when a level (re)loads so a fresh
# level always starts with nothing to restart, since this autoload persists.
func clear_turn_snapshot() -> void:
	turn_start_states.clear()
	_set_snapshot_taken(false)
	_clear_move_history()

func _set_snapshot_taken(value: bool) -> void:
	_snapshot_taken = value
	_refresh_restart_availability()

func _refresh_restart_availability() -> void:
	var available := _snapshot_taken and restart_uses_remaining > 0
	if available == _restart_available:
		return
	_restart_available = available
	restart_availability_changed.emit(available)

func _cleanup_freed_players() -> void:
	players = players.filter(func(p): return is_instance_valid(p))
	if not is_instance_valid(active_player):
		active_player = players[0] if players.size() > 0 else null

func reset() -> void:
	turn_count = 0
	active_player = null
	players.clear()
	turn_start_states.clear()
	_snapshot_taken = false
	_restart_available = false
	move_history.clear()
	_undo_available = false
	restart_uses_remaining = MAX_RESTART_USES
