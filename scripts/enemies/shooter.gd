class_name Shooter
extends Enemy
## "Kiln Crab": stationary. Faces Feebus when he is in range, flashes as a
## warning, then fires a slow ember. Two hits, or one stomp plus one peck.

const RANGE := 230.0
const FIRE_INTERVAL := 2.2
const TELEGRAPH := 0.45
const SHOT_SPEED := 110.0

var _timer := 1.0

func _init() -> void:
	max_hp = 2
	body_size = Vector2(18, 12)

func _behave(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = 0.0
	move_and_slide()
	var p := _player()
	if p == null:
		return
	var to_p := p.global_position - global_position
	if absf(to_p.x) > RANGE or absf(to_p.y) > 80.0:
		_timer = minf(_timer + delta, FIRE_INTERVAL) # rearm slowly while idle
		return
	var new_facing := 1 if to_p.x > 0.0 else -1
	if new_facing != facing:
		facing = new_facing
		queue_redraw()
	_timer -= delta
	if _timer <= TELEGRAPH:
		queue_redraw()
	if _timer <= 0.0:
		_fire()
		_timer = FIRE_INTERVAL

func _fire() -> void:
	var shot := Projectile.new()
	shot.velocity = Vector2(facing * SHOT_SPEED, 0.0)
	shot.position = global_position + Vector2(facing * 12, -7)
	get_parent().add_child(shot)
	queue_redraw()

func _draw() -> void:
	var f := float(facing)
	var warn := _timer <= TELEGRAPH
	draw_rect(Rect2(-9, -12, 18, 12), Color("9d0208"))
	draw_rect(Rect2(-9, -12, 18, 3), Color("ffba08") if warn else Color("6a040f"))
	draw_circle(Vector2(10 * f, -7), 4.0 if warn else 3.0, Color("ffba08") if warn else Color("dc2f02")) # claw / cannon
	draw_circle(Vector2(-3, -9), 1.3, Color.WHITE)
	draw_circle(Vector2(3, -9), 1.3, Color.WHITE)
