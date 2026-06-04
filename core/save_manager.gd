extends Node

const SAVE_PATH = "user://savegame.cfg"

func save_position(grid_pos: Vector2i) -> void:
	var config = ConfigFile.new()
	config.set_value("player", "grid_x", grid_pos.x)
	config.set_value("player", "grid_y", grid_pos.y)
	config.save(SAVE_PATH)

func load_position() -> Vector2i:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return Vector2i(-1, -1)  # tanda belum ada save
	var x = config.get_value("player", "grid_x", -1)
	var y = config.get_value("player", "grid_y", -1)
	return Vector2i(x, y)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
