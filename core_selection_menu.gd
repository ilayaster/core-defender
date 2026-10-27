extends MarginContainer

@onready var slow_btn = $VBoxContainer/CenterContainer/VBoxContainer/SlowCoreButton
@onready var plosive_btn = $VBoxContainer/CenterContainer/VBoxContainer/PlosiveCoreButton

func _ready():
	slow_btn.pressed.connect(_on_slow_pressed)
	plosive_btn.pressed.connect(_on_plosive_pressed)

func _on_slow_pressed():
	GameState.selected_core = GameState.CoreType.SLOW
	get_tree().change_scene_to_file("res://game.tscn")

func _on_plosive_pressed():
	GameState.selected_core = GameState.CoreType.PLOSIVE
	get_tree().change_scene_to_file("res://game.tscn")
