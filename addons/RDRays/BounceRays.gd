## BouncingRays — генератор лучей с отражением, преломлением и затуханием,
## Класс создает настраиваемые _draw лучи,
## которые могут автоматически
## реагировать на колизию находящуюся внутри Area2D.
extends Node2D
class_name BouncingRays



@export_group("RaySettings")
@export var spawn_position: Vector2 = Vector2.ZERO
@export var ray_count: int = 36
@export var ray_length: float = 400
@export var ray_speed: float = 200
@export var max_reflections: int = 3
@export var ray_color: Color = Color(1, 1, 0)

@export_range(0.0, 1.0, 0.01) var reflection_ratio: float = 0.1
@export_range(0.0, 1.0, 0.01) var transmission_ratio: float = 0.9
@export var refraction_factor: float = 1.5
@export_range(0.0, 1.0, 0.01) var intensity_loss_reflect: float = 0.05
@export_range(0.0, 1.0, 0.01) var intensity_loss_refract: float = 0.02
@export var attenuation_per_unit: float = 0.0005

var rays: Array = []

func _ready():
	for i in range(ray_count):
		var angle = (TAU / ray_count) * i
		var direction = Vector2(cos(angle), sin(angle))
		rays.append({
			"position": spawn_position,
			"direction": direction.normalized(),
			"reflections_left": max_reflections,
			"intensity": 1.0,
			"inside": false,
			"history": [spawn_position]
		})

func _physics_process(delta):
	move_rays(delta)
	queue_redraw()

func move_rays(delta):
	var space_state = get_world_2d().direct_space_state
	for ray in rays:
		if ray["reflections_left"] <= 0 or ray["intensity"] <= 0.02:
			continue

		var move_dist = ray_speed * delta
		var start_pos = ray["position"]
		var end_pos = start_pos + ray["direction"] * move_dist

		var query = PhysicsRayQueryParameters2D.new()
		query.from = start_pos
		query.to = end_pos
		query.collide_with_bodies = true
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)

		if result:
			end_pos = result.position
			var normal = result.normal.normalized()

			if reflection_ratio > 0.0:
				var reflected_dir = ray["direction"].bounce(normal).normalized()
				var reflected = {
					"position": end_pos + reflected_dir * 0.1,
					"direction": reflected_dir,
					"reflections_left": ray["reflections_left"] - 1,
					"intensity": ray["intensity"] * reflection_ratio * (1.0 - intensity_loss_reflect),
					"inside": ray["inside"],
					"history": [end_pos]
				}
				rays.append(reflected)

			if transmission_ratio > 0.0:
				var eta = (1.0 / refraction_factor) if not ray["inside"] else refraction_factor
				var use_normal = normal if not ray["inside"] else -normal
				var refracted_dir = refract(ray["direction"], use_normal, eta)

				if refracted_dir != Vector2.ZERO:
					var transmitted = {
						"position": end_pos + refracted_dir * 0.1,
						"direction": refracted_dir,
						"reflections_left": ray["reflections_left"] - 1,
						"intensity": ray["intensity"] * transmission_ratio * (1.0 - intensity_loss_refract),
						"inside": not ray["inside"],
						"history": [end_pos]
					}
					rays.append(transmitted)

			ray["reflections_left"] = 0

		ray["intensity"] -= move_dist * attenuation_per_unit
		ray["intensity"] = clamp(ray["intensity"], 0.0, 1.0)

		ray["position"] = end_pos
		ray["history"].append(end_pos)

func refract(incident: Vector2, normal: Vector2, eta: float) -> Vector2:
	var cos_i = -incident.dot(normal)
	var sin_t2 = eta * eta * (1.0 - cos_i * cos_i)
	if sin_t2 > 1.0:
		return Vector2.ZERO
	var cos_t = sqrt(1.0 - sin_t2)
	return eta * incident + (eta * cos_i - cos_t) * normal

func _draw():
	for ray in rays:
		if ray["history"].size() > 1:
			var alpha = clamp(ray["intensity"], 0.0, 1.0) * ray_color.a
			var draw_col = Color(ray_color.r, ray_color.g, ray_color.b, alpha)
			for i in range(ray["history"].size() - 1):
				draw_line(ray["history"][i], ray["history"][i + 1], draw_col, 2)
