class_name Walker
extends Enemy
## "Ember Slug": patrols, turns at walls and ledges. One hit to kill.

const SPEED := 35.0

func _init() -> void:
	max_hp = 1
	body_size = Vector2(16, 10)

func _behave(delta: float) -> void:
	if is_on_floor() and (is_on_wall() or not _ground_ahead()):
		facing = -facing
		queue_redraw()
	velocity.x = facing * SPEED
	_apply_gravity(delta)
	move_and_slide()

func _ground_ahead() -> bool:
	var from := global_position + Vector2(facing * (body_size.x / 2.0 + 2.0), -2.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 10), 1)
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()

func _draw() -> void:
	var f := float(facing)
	draw_rect(Rect2(-8, -10, 16, 10), Color("e85d04"))
	draw_rect(Rect2(-8, -10, 16, 3), Color("ffba08"))  # glowing back
	draw_circle(Vector2(5 * f, -7), 1.5, Color.BLACK)
	draw_line(Vector2(6 * f, -10), Vector2(8 * f, -14), Color("e85d04"), 1.0) # eye stalk
