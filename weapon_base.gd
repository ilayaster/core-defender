extends Node2D
class_name WeaponBase

# Сигналы для связи с игроком (например, чтобы проиграть звук или нанести урон)
signal attacked(damage: float)
signal reload_finished()

enum State { IDLE, WINDUP, ATTACK, COOLDOWN, RELOADING }

@export_group("Основные параметры")
@export var weapon_name: String = "Weapon"
@export var damage: float = 10.0
@export var windup_duration: float = 0.0
@export var attack_duration: float = 0.15   # Время, пока хитбокс активен
@export var cooldown_duration: float = 0.5

@export_group("Патроны (0 = бесконечно)")
@export var max_ammo: int = 0
@export var reload_duration_base: float = 1.5 # Базовое время полной перезарядки

var current_state: State = State.IDLE
var current_ammo: int = 0
var timer: float = 0.0

# Ссылки на ноды (мы добавим их в сцену оружия)
@onready var hitbox_area: Area2D = $HitboxArea
@onready var visuals: Node2D = $WeaponVisuals

func _ready():
	current_ammo = max_ammo
	if hitbox_area:
		_set_hitbox_active(false)

func _process(delta: float):
	if current_state != State.IDLE:
		timer -= delta
		if visuals:
			visuals.update_progress(timer, _get_max_timer(), current_state, current_ammo, max_ammo)
		
		if timer <= 0.0:
			_transition_state()

func request_attack() -> bool:
	if current_state == State.RELOADING:
		return false # Можно добавить проигрывание звука "щелчок"
	if current_state != State.IDLE:
		return false
		
	# Автоматическая перезарядка, если патроны кончились
	if max_ammo > 0 and current_ammo <= 0:
		request_reload()
		return false
		
	if max_ammo > 0:
		current_ammo -= 1
		
	# Если взмаха нет, сразу переходим к атаке
	var first_state = State.WINDUP if windup_duration > 0.0 else State.ATTACK
	_change_state(first_state)
	return true

func request_reload():
	if max_ammo == 0 or current_ammo == max_ammo or current_state == State.RELOADING:
		return
	
	# Чем больше патронов осталось, тем быстрее перезарядка
	var time_multiplier = 1.0 - (float(current_ammo) / float(max_ammo))
	timer = reload_duration_base * time_multiplier
	_change_state(State.RELOADING)

func _change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.WINDUP:
			timer = windup_duration
		State.ATTACK:
			timer = attack_duration
			_set_hitbox_active(true)
			emit_signal("attacked", damage)
		State.COOLDOWN:
			timer = cooldown_duration
			_set_hitbox_active(false)
		State.RELOADING:
			pass # timer уже установлен в request_reload
	
	if visuals:
		visuals.update_progress(timer, _get_max_timer(), current_state, current_ammo, max_ammo)

func _transition_state():
	match current_state:
		State.WINDUP:
			_change_state(State.ATTACK)
		State.ATTACK:
			_change_state(State.COOLDOWN)
		State.COOLDOWN:
			_change_state(State.IDLE)
		State.RELOADING:
			current_ammo = max_ammo
			_change_state(State.IDLE)
			emit_signal("reload_finished")

func _set_hitbox_active(is_active: bool):
	if hitbox_area:
		hitbox_area.monitoring = is_active
		for child in hitbox_area.get_children():
			if child is CollisionShape2D:
				child.disabled = not is_active

func _get_max_timer() -> float:
	match current_state:
		State.WINDUP: return windup_duration
		State.ATTACK: return attack_duration
		State.COOLDOWN: return cooldown_duration
		State.RELOADING: return reload_duration_base
	return 0.0
