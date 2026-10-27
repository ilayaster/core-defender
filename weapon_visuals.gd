extends Node2D

var current_time: float = 0.0
var max_time: float = 1.0
var state: int = 0
var ammo: int = 0
var max_ammo: int = 0

const STATE_IDLE = 0
const STATE_WINDUP = 1
const STATE_ATTACK = 2
const STATE_COOLDOWN = 3
const STATE_RELOADING = 4

func update_progress(c_time: float, m_time: float, st: int, a: int, m_a: int):
	current_time = c_time
	max_time = m_time
	state = st
	ammo = a
	max_ammo = m_a
	queue_redraw() # Перерисовать кадр

func _draw():
	if max_time <= 0.0 and state != STATE_RELOADING:
		return
		
	var progress = 1.0 - (current_time / max_time) if max_time > 0 else 1.0
	progress = clamp(progress, 0.0, 1.0)
	
	var base_radius = 24.0
	var bg_color = Color(0.2, 0.2, 0.2, 0.8)
	var fg_color = Color.WHITE
	
	match state:
		STATE_WINDUP: fg_color = Color(0.8, 0.8, 0.8)    # Серый
		STATE_ATTACK: fg_color = Color(1.0, 0.3, 0.3)    # Красный
		STATE_COOLDOWN: fg_color = Color(1.0, 0.8, 0.0)  # Желтый
		STATE_RELOADING: fg_color = Color(0.0, 1.0, 1.0) # Циан

	# Фоновый круг
	draw_circle(Vector2.ZERO, base_radius, bg_color)
	
	# Дуга прогресса (от -90 градусов по кругу)
	if progress > 0.0:
		draw_arc(Vector2.ZERO, base_radius, -PI/2, -PI/2 + (2 * PI * progress), 32, fg_color, 4.0, true)
		
	# Точки патронов (рисуем ниже круга)
	if max_ammo > 0:
		_draw_ammo_dots(base_radius + 16.0, ammo, max_ammo)

func _draw_ammo_dots(offset_y: float, current: int, maximum: int):
	var dot_radius = 3.0
	var spacing = 8.0
	var total_width = (maximum - 1) * spacing
	var start_x = -total_width / 2.0
	
	for i in range(maximum):
		var x = start_x + i * spacing
		var pos = Vector2(x, offset_y)
		if i < current:
			draw_circle(pos, dot_radius, Color.WHITE)
		else:
			draw_circle(pos, dot_radius, Color(0.4, 0.4, 0.4))
