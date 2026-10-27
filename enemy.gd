extends CharacterBody2D

@export var base_speed: float = 80.0
@export var max_health: int = 30
@export var damage_to_core: int = 20
@export var hit_distance: float = 40.0

var current_health: int
var is_slowed: bool = false

@onready var anim_sprite = $AnimatedSprite2D
@onready var click_area = $ClickArea

func _ready():
	current_health = max_health
	add_to_group("enemies")
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)
	if anim_sprite:
		anim_sprite.play("walk")

func _physics_process(_delta):
	var core = get_tree().get_first_node_in_group("core")
	if core:
		var distance_to_core = global_position.distance_to(core.global_position)
		
		if distance_to_core < hit_distance:
			core.take_damage(damage_to_core)
			die()
			return
			
		var direction = global_position.direction_to(core.global_position)
		velocity = direction * base_speed
		move_and_slide()
		
		if anim_sprite and direction.x != 0:
			anim_sprite.flip_h = direction.x < 0

func _on_click_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		take_damage(15)

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	# ПРОВЕРКА: если нода всё ещё в дереве сцен
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			tree.call_group("game", "on_enemy_killed")
		queue_free()

func apply_slow(factor: float):
	if not is_slowed:
		is_slowed = true
		base_speed = base_speed * factor

func remove_slow():
	if is_slowed:
		is_slowed = false
		var game_node = get_tree().get_first_node_in_group("game")
		if game_node:
			base_speed = game_node.current_enemy_speed
		else:
			base_speed = 80.0
