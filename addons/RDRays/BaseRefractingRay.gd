## Класс Создает один луч,
## и рисует круг - соответственно базового отражения.
extends Node2D
class_name BaseRefractingRay

@export var MRA = false
@export var PRA = false
@export var ro = Vector2(220, 330) # start_ray
@export var rd = Vector2.ZERO      # direction
@export var ra = 50.0              # radius
@export var hit_point: Vector2
@export var has_hit := false
@export var reflect_dir: Vector2
@export var ce = Vector2(200, 200) # center
@onready var RAngleData = float($Panel/RAngle.text)

func circle_intersect(ro: Vector2, rd: Vector2, ce: Vector2, ra: float) -> Vector2:
	var oc = ro - ce
	var b = oc.dot(rd)
	var c = oc.dot(oc) - ra * ra
	var h = b * b - c
	if h < 0.0:
		return Vector2(-1.0, -1.0)
	h = sqrt(h)
	return Vector2(-b - h, -b + h)

func test_circle_intersect(tciRO: Vector2, tciAngle: float, tciRA: float):
	ro = tciRO
	ra = tciRA

	var angle_rad = deg_to_rad(tciAngle)
	rd = Vector2(cos(angle_rad), sin(angle_rad)).normalized()

	var result = circle_intersect(ro, rd, ce, ra)
	if result.x >= 0 or result.y >= 0:
		var t = min(result.x, result.y)
		hit_point = ro + rd * t
		has_hit = true

		# normal at the point of collision
		var normal = (hit_point - ce).normalized()

		# reflected direction
		reflect_dir = rd - 2.0 * rd.dot(normal) * normal
	else:
		has_hit = false

	queue_redraw()

func _ready():
	pass
	#test_circle_intersect(Vector2(220, 330), -90.0, 50.0)
func _process(delta: float) -> void:
	var MethodRCF = float($Panel/Method.text)
	if MRA:
		var RAngleDataFloatlocal = float($Panel/RAngle.text)
		var RAngleDataFloatlocalNEW 
		RAngleDataFloatlocalNEW = RAngleData - float($Panel/PMARfob.text)
		$Panel/RAngle.text = str(RAngleDataFloatlocalNEW)
		RAngleData = float($Panel/RAngle.text)
	elif PRA:
		var RAngleDataFloatlocal = float($Panel/RAngle.text)
		var RAngleDataFloatlocalNEW 
		RAngleDataFloatlocalNEW = RAngleData + float($Panel/PMARfob.text)
		$Panel/RAngle.text = str(RAngleDataFloatlocalNEW)
		RAngleData = float($Panel/RAngle.text)
	if MethodRCF == 1.0:
		
		test_circle_intersect(Vector2(float($Panel/RposX.text), float($Panel/RposY.text)), RAngleData, float($Panel/CircleRadius.text))
		ce = Vector2(float($Panel/CirclePosX.text),float($Panel/CirclePosY.text))

func _draw():
	# background
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.05, 0.05, 0.05))

	# Circle (surface)
	draw_circle(ce, ra, Color(0.1, 0.4, 1.0, 0.2)) # прозрачная заливка
	draw_arc(ce, ra, 0, TAU, 64, Color(0.3, 0.8, 1.0), 2) # обводка

	# Ray (falling)
	draw_line(ro, ro + rd * 400, Color.YELLOW, 2)

	if has_hit:
		# Intersection point
		draw_circle(hit_point, 5, Color.RED)

		# reflected ray
		draw_line(hit_point, hit_point + reflect_dir * 200, Color.CYAN, 2)

		# Visual normal
		var normal = (hit_point - ce).normalized()
		draw_line(hit_point, hit_point + normal * 40, Color.GREEN, 1)





func _on_MAray_angle_button_down() -> void: #PRESSED
	MRA = true


func _on_Mray_angle_button_up() -> void: #RELEASED
	MRA = false


func _on_Pray_angle_button_down() -> void: #PRESSED
	PRA = true


func _on_Pray_angle_button_up() -> void: #RELEASED
	PRA = false
