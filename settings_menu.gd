extends MarginContainer

@onready var display_mode_option = $MainContainer/DisplaySettings/DisplayModeOption
@onready var resolution_option = $MainContainer/ResolutionSettings/ResolutionOption
@onready var master_slider = $MainContainer/AudioSettings/MasterVolume/MasterSlider
@onready var music_slider = $MainContainer/AudioSettings/MusicVolume/MusicSlider
@onready var sfx_slider = $MainContainer/AudioSettings/SFXVolume/SFXSlider
@onready var back_button = $MainContainer/BackButton

func _ready():
	# Устанавливаем текущие значения из SettingsManager
	# Исправлен warning: кастуем enum в int
	display_mode_option.selected = SettingsManager.display_mode as int
	
	# Устанавливаем разрешение
	var current_res = SettingsManager.screen_resolution
	match current_res:
		Vector2i(1280, 720):
			resolution_option.selected = 0
		Vector2i(1920, 1080):
			resolution_option.selected = 1
		Vector2i(1280, 800):
			resolution_option.selected = 2
		Vector2i(1600, 900):
			resolution_option.selected = 3
		_:
			resolution_option.selected = 0
	
	# Устанавливаем ползунки громкости
	master_slider.value = SettingsManager.master_volume * 100
	music_slider.value = SettingsManager.music_volume * 100
	sfx_slider.value = SettingsManager.sfx_volume * 100
	
	# Подключаем сигналы
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	# ОТЛАДКА: проверяем, что кнопка найдена
	print("BackButton найден: ", back_button != null)

func _on_display_mode_selected(index: int):
	print("Выбран режим отображения: ", index)
	SettingsManager.set_display_mode(index)

func _on_resolution_selected(index: int):
	var resolutions = [
		Vector2i(1280, 720),
		Vector2i(1920, 1080),
		Vector2i(1280, 800),
		Vector2i(1600, 900)
	]
	
	if index < resolutions.size():
		SettingsManager.set_resolution(resolutions[index])

func _on_master_volume_changed(value: float):
	SettingsManager.set_master_volume(value / 100.0)

func _on_music_volume_changed(value: float):
	SettingsManager.set_music_volume(value / 100.0)

func _on_sfx_volume_changed(value: float):
	SettingsManager.set_sfx_volume(value / 100.0)

func _on_back_pressed():
	print("Нажата кнопка Back")
	get_tree().change_scene_to_file("res://main_menu.tscn")
