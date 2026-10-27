extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var time_label = $UI/VBoxContainer/TimeLabel
@onready var core_health_label = $UI/VBoxContainer/CoreHealthLabel

const MAX_TIME: float = 600.0 # 10 минут в секундах
var time_elapsed: float = 0.0

var core_node: Node2D
var current_enemy_speed: float = 80.0
var difficulty_multiplier: float = 1.0

func _ready():
	add_to_group("game")
	GameState.game_active = true
	spawn_core()
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func spawn_core():
	var core_scene = null
	if GameState.selected_core == GameState.CoreType.SLOW:
		core_scene = preload("res://entities/slow_core.tscn")
	else:
		core_scene = preload("res://entities/core_plosive.tscn")
	
	core_node = core_scene.instantiate()
	core_node.global_position = $CoreSpawnPoint.global_position
	add_child(core_node)
	update_ui()

func _on_spawn_timer_timeout():
	if not GameState.game_active:
		return
	spawn_enemy()

func spawn_enemy():
	var enemy_scene = preload("res://entities/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	var viewport_size = get_viewport_rect().size
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match edge:
		0: spawn_pos = Vector2(randf_range(0, viewport_size.x), -50)
		1: spawn_pos = Vector2(randf_range(0, viewport_size.x), viewport_size.y + 50)
		2: spawn_pos = Vector2(-50, randf_range(0, viewport_size.y))
		3: spawn_pos = Vector2(viewport_size.x + 50, randf_range(0, viewport_size.y))
		
	enemy.global_position = spawn_pos
	
	# Прогрессия сложности на основе прошедшего времени
	difficulty_multiplier = 1.0 + (time_elapsed / MAX_TIME) * 1.5
	
	enemy.max_health = int(30 * difficulty_multiplier)
	current_enemy_speed = 80.0 + (difficulty_multiplier * 15)
	enemy.base_speed = current_enemy_speed

func game_over(won: bool):
	GameState.game_active = false
	spawn_timer.stop()
	print("Игра окончена. Победа: ", won)
	get_tree().change_scene_to_file("res://main_menu.tscn")

func on_enemy_killed():
	pass

func update_ui():
	if core_node:
		core_health_label.text = "Core HP: %d/%d" % [core_node.current_health, core_node.max_health]

func _process(delta):
	if GameState.game_active:
		time_elapsed += delta
		
		# Проверка на победу по времени
		if time_elapsed >= MAX_TIME:
			game_over(true)
			return
		
		var minutes = int(time_elapsed / 60)
		var seconds = int(time_elapsed) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]
		
		update_ui()
