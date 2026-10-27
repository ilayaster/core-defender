extends MarginContainer

# Перетяни сюда кнопки в инспекторе или найди их через get_node
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	# Подключаем сигналы нажатия к нашим функциям
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://core_selection_menu.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
