extends Node

enum DisplayMode { WINDOWED, WINDOWED_FULLSCREEN, FULLSCREEN }

var display_mode: DisplayMode = DisplayMode.WINDOWED_FULLSCREEN
var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var screen_resolution: Vector2i = Vector2i(1280, 720)

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	load_settings()
	call_deferred("apply_settings")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	
	if err == OK:
		display_mode = config.get_value("display", "mode", DisplayMode.WINDOWED_FULLSCREEN)
		master_volume = config.get_value("audio", "master", 0.8)
		music_volume = config.get_value("audio", "music", 0.7)
		sfx_volume = config.get_value("audio", "sfx", 0.8)
		var res_x = config.get_value("display", "resolution_x", 1280)
		var res_y = config.get_value("display", "resolution_y", 720)
		screen_resolution = Vector2i(res_x, res_y)
	else:
		display_mode = DisplayMode.WINDOWED_FULLSCREEN
		master_volume = 0.8
		music_volume = 0.7
		sfx_volume = 0.8
		screen_resolution = Vector2i(1280, 720)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("display", "mode", display_mode)
	config.set_value("display", "resolution_x", screen_resolution.x)
	config.set_value("display", "resolution_y", screen_resolution.y)
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.save(SETTINGS_PATH)

func apply_settings():
	# Используем call_deferred для применения настроек окна
	call_deferred("_apply_display_settings")
	_apply_audio_settings()

func _apply_display_settings():
	match display_mode:
		DisplayMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(screen_resolution)
			# Центрируем окно (исправлено целочисленное деление)
			var screen_size = DisplayServer.screen_get_size()
			var pos = Vector2i((screen_size.x - screen_resolution.x) / 2, (screen_size.y - screen_resolution.y) / 2)
			DisplayServer.window_set_position(pos)
			
		DisplayMode.WINDOWED_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			
		DisplayMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _apply_audio_settings():
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func set_display_mode(mode: int):
	display_mode = mode as DisplayMode  # Исправлен warning с enum
	apply_settings()
	save_settings()

func set_resolution(res: Vector2i):
	screen_resolution = res
	if display_mode == DisplayMode.WINDOWED:
		apply_settings()
	save_settings()

func set_master_volume(value: float):
	master_volume = value
	_apply_audio_settings()
	save_settings()

func set_music_volume(value: float):
	music_volume = value
	_apply_audio_settings()
	save_settings()

func set_sfx_volume(value: float):
	sfx_volume = value
	_apply_audio_settings()
	save_settings()
