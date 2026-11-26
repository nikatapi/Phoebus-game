class_name Player
extends CharacterBody2D
## Feebus the goldfinch. Movement is tuned to forgive touch controls:
## coyote time, jump buffering, variable jump height, one flutter, glide.

const RUN_SPEED := 140.0
const ACCEL := 1000.0
const AIR_ACCEL := 750.0
const FRICTION := 1200.0
const GRAVITY := 950.0
const MAX_FALL := 330.0
const GLIDE_FALL := 55.0
const JUMP_VELOCITY := -310.0
const FLUTTER_VELOCITY := -250.0
const JUMP_CUT := 0.45
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.15

const DASH_SPEED := 380.0
const DASH_TIME := 0.16
const DASH_COOLDOWN := 0.45

const KILL_Y := 600.0

const MAX_HEARTS := 3
const INVULN_TIME := 1.0
const HURT_LOCK := 0.25
const KNOCKBACK := Vector2(170, -190)
const STOMP_BOUNCE := -260.0

const PECK_TIME := 0.12
const PECK_COOLDOWN := 0.28
const PECK_RANGE := Vector2(22, 14)

## Physics layers: 1 world, 2 player, 3 enemies, 4 enemy projectiles.
const MASK_WORLD := 1
const MASK_ENEMY := 4
const MASK_ENEMY_SHOT := 8

signal health_changed(hearts: int, max_hearts: int)
signal died

var spawn_point := Vector2.ZERO
var facing := 1
var max_flutters := 1

var _coyote := 0.0
var _buffer := 0.0
var _flutters := 0
var _gliding := false
var _dash_time := 0.0
var _dash_cooldown := 0.0

var hearts := MAX_HEARTS
var _invuln := 0.0
var _hurt_lock := 0.0
var _peck_time := 0.0
var _peck_cooldown := 0.0

func _ready() -> void:
	spawn_point = global_position
	collision_layer = 2
	collision_mask = MASK_WORLD

func _process(delta: float) -> void:
	if _invuln > 0.0:
		_invuln -= delta
		modulate.a = 0.35 if fmod(_invuln, 0.12) < 0.06 else 1.0
	else:
		modulate.a = 1.0

func _physics_process(delta: float) -> void:
	_dash_cooldown = maxf(_dash_cooldown - delta, 0.0)
	_peck_cooldown = maxf(_peck_cooldown - delta, 0.0)
	_hurt_lock = maxf(_hurt_lock - delta, 0.0)
	if _peck_time > 0.0:
		_peck_time -= delta
		if _peck_time <= 0.0:
			queue_redraw()

	if _hurt_lock <= 0.0:
		if Input.is_action_just_pressed("swap_power"):
			GameState.swap_active()
		if Input.is_action_just_pressed("power"):
			_use_power()
		if Input.is_action_just_pressed("attack"):
			_peck()

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity = Vector2(facing * DASH_SPEED, 0.0)
		move_and_slide()
		_hit_in_front(Vector2(facing * 14, -8), Vector2(20, 16), MASK_ENEMY | MASK_ENEMY_SHOT, 1)
		return

	if _hurt_lock > 0.0:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		return

	_horizontal(delta)
	_vertical(delta)
	move_and_slide()

	if global_position.y > KILL_Y:
		_fell_in_pit()

func _horizontal(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	var accel := ACCEL if is_on_floor() else AIR_ACCEL
	if absf(dir) > 0.1:
		velocity.x = move_toward(velocity.x, dir * RUN_SPEED, accel * delta)
		var new_facing := 1 if dir > 0.0 else -1
		if new_facing != facing:
			facing = new_facing
			queue_redraw()
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

func _vertical(delta: float) -> void:
	if is_on_floor():
		_coyote = COYOTE_TIME
		_flutters = max_flutters
	else:
		_coyote -= delta

	if Input.is_action_just_pressed("jump"):
		_buffer = JUMP_BUFFER
	else:
		_buffer -= delta

	if _buffer > 0.0:
		if _coyote > 0.0:
			velocity.y = JUMP_VELOCITY
			_coyote = 0.0
			_buffer = 0.0
		elif _flutters > 0:
			velocity.y = FLUTTER_VELOCITY
			_flutters -= 1
			_buffer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

	var was_gliding := _gliding
	_gliding = not is_on_floor() and velocity.y > 0.0 and Input.is_action_pressed("jump")
	if _gliding:
		velocity.y = minf(velocity.y, GLIDE_FALL)
	if was_gliding != _gliding:
		queue_redraw()

func _use_power() -> void:
	match GameState.active_sign():
		"aries":
			if _dash_cooldown <= 0.0:
				_dash_time = DASH_TIME * (1.3 if GameState.is_in_season("aries") else 1.0)
				_dash_cooldown = DASH_COOLDOWN
				_break_walls_ahead()
		_:
			pass # Other signs are implemented as their worlds are built.

func _break_walls_ahead() -> void:
	for body in _query(Vector2(facing * 24, -8), Vector2(40, 16), MASK_WORLD, false):
		if body.has_method("smash"):
			body.call("smash")

# --- Combat -----------------------------------------------------------------

func _peck() -> void:
	if _peck_cooldown > 0.0:
		return
	_peck_cooldown = PECK_COOLDOWN
	_peck_time = PECK_TIME
	queue_redraw()
	_hit_in_front(Vector2(facing * (6 + PECK_RANGE.x / 2.0), -10), PECK_RANGE,
		MASK_ENEMY | MASK_ENEMY_SHOT, 1)

func _hit_in_front(offset: Vector2, size: Vector2, mask: int, damage: int) -> void:
	for target in _query(offset, size, mask, true):
		if target.has_method("hurt"):
			target.call("hurt", damage, global_position)

func _query(offset: Vector2, size: Vector2, mask: int, areas: bool) -> Array[Object]:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	query.shape = shape
	query.transform = Transform2D(0.0, global_position + offset)
	query.collision_mask = mask
	query.collide_with_bodies = true
	query.collide_with_areas = areas
	var out: Array[Object] = []
	for hit in get_world_2d().direct_space_state.intersect_shape(query, 16):
		var c: Object = hit["collider"]
		if c != null and c not in out:
			out.append(c)
	return out

func is_dashing() -> bool:
	return _dash_time > 0.0

## Called by enemies on contact. Returns true if the hit landed.
func take_damage(amount: int, from: Vector2) -> bool:
	if _invuln > 0.0 or is_dashing() or hearts <= 0:
		return false
	hearts = maxi(hearts - amount, 0)
	health_changed.emit(hearts, MAX_HEARTS)
	if hearts == 0:
		_die()
		return true
	_invuln = INVULN_TIME
	_hurt_lock = HURT_LOCK
	var away := 1.0 if global_position.x >= from.x else -1.0
	velocity = Vector2(away * KNOCKBACK.x, KNOCKBACK.y)
	return true

## Called by enemies when Feebus lands on them.
func stomp_bounce() -> void:
	velocity.y = STOMP_BOUNCE
	_flutters = max_flutters # reward: stomping refreshes the flutter

func heal_full() -> void:
	hearts = MAX_HEARTS
	health_changed.emit(hearts, MAX_HEARTS)

func _fell_in_pit() -> void:
	# A pit costs one heart and returns you to the last checkpoint.
	hearts = maxi(hearts - 1, 0)
	if hearts == 0:
		_die()
		return
	health_changed.emit(hearts, MAX_HEARTS)
	_reset_to_checkpoint()
	_invuln = INVULN_TIME

func _die() -> void:
	died.emit()
	_reset_to_checkpoint()
	heal_full()
	_invuln = INVULN_TIME

func _reset_to_checkpoint() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
	_dash_time = 0.0
	_hurt_lock = 0.0

func respawn() -> void:
	_reset_to_checkpoint()

# --- Placeholder art: a goldfinch drawn with primitives ---------------------

func _draw() -> void:
	var f := float(facing)
	var body := Color("c9a77c")
	var red := Color("d62828")
	var black := Color("111111")
	var yellow := Color("ffd60a")
	var white := Color("f5f5f5")
	draw_circle(Vector2(-1 * f, -6), 7.0, body)                      # body
	draw_rect(Rect2(-6 * f - (8 if f < 0 else 0), -9, 8, 3), black)  # wing
	draw_rect(Rect2(-6 * f - (8 if f < 0 else 0), -6, 8, 2), yellow) # wing bar
	if _gliding:
		draw_rect(Rect2(-12, -11, 24, 2), yellow)                     # spread wings
	draw_circle(Vector2(4 * f, -12), 5.0, white)                     # head
	draw_rect(Rect2(1 * f - (6 if f < 0 else 0), -17, 6, 3), black)  # cap
	draw_circle(Vector2(6 * f, -11), 2.5, red)                       # red face
	draw_circle(Vector2(4 * f, -13), 1.0, black)                     # eye
	var beak_tip := 18.0 if _peck_time > 0.0 else 12.0              # beak lunges on peck
	draw_colored_polygon(PackedVector2Array([
		Vector2(8 * f, -12), Vector2(beak_tip * f, -11), Vector2(8 * f, -10)]), Color("e8d8c0"))
	if _peck_time > 0.0:
		var start := -1.2 if f > 0 else PI - 1.2
		draw_arc(Vector2((beak_tip + 4) * f, -11), 5.0, start, start + 2.4, 8, Color(1, 1, 1, 0.8), 1.5)
