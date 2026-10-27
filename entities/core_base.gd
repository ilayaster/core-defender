extends Area2D

@export var max_health: int = 100
@export var explosion_damage: int = 9999
@export var core_type: String = "slow"

var current_health: int

@onready var sprite = $Sprite2D
@onready var explosion_area = $ExplosionArea
@onready var slow_aura = $SlowAura if has_node("SlowAura") else null

func _ready():
	current_health = max_health
	add_to_group("core")
	
	print("Ядро создано. HP: ", current_health)
	
	# Настройка взрыва
	if explosion_area:
		explosion_area.monitoring = true
		explosion_area.body_entered.connect(_on_explosion_body_entered)
		
		var shape_node = explosion_area.get_node("CollisionShape2D")
		if shape_node and shape_node.shape is CircleShape2D:
			var actual_radius = shape_node.shape.radius
			print("Радиус взрыва из хитбокса: ", actual_radius)
	
	# Настройка slow-core
	if core_type == "slow" and slow_aura:
		slow_aura.monitoring = true
		slow_aura.body_entered.connect(_on_aura_body_entered)
		slow_aura.body_exited.connect(_on_aura_body_exited)
	elif slow_aura:
		slow_aura.queue_free()

func take_damage(amount: int):
	print("Ядро получает урон: ", amount, " | Текущее HP: ", current_health, " -> ", current_health - amount)
	
	# ВЗРЫВ ПРИ КАЖДОМ ПОЛУЧЕНИИ УРОНА
	detonate()
	
	current_health -= amount
	
	# Проверка на смерть
	if current_health <= 0:
		print("Ядро умирает!")
		GameState.game_active = false
		get_tree().call_group("game", "game_over", false)
		queue_free()

func detonate():
	print("=== ВЗРЫВ ===")
	
	if explosion_area:
		var bodies = explosion_area.get_overlapping_bodies()
		print("Найдено тел в радиусе взрыва: ", bodies.size())
		
		for body in bodies:
			print("  Тело: ", body.name, " | Группа enemies: ", body.is_in_group("enemies"))
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				print("  -> Наносим урон ", explosion_damage)
				body.take_damage(explosion_damage)
	else:
		print("ОШИБКА: ExplosionArea не найдена!")

func _on_explosion_body_entered(_body):
	pass

func _on_aura_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("apply_slow"):
		body.apply_slow(0.5)

func _on_aura_body_exited(body):
	if body.is_in_group("enemies") and body.has_method("remove_slow"):
		body.remove_slow()
