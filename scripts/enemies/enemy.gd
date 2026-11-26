class_name Enemy
extends CharacterBody2D
## Base enemy: hit points, contact damage, stomp detection, hit flash,
## stun (for Leo's Roar later). Subclasses implement _behave(delta).
##
## Physics layers: enemies sit on layer 3 (value 4) and collide only with
## the world, so Feebus passes through them; contact is detected by an
## Area2D hurtbox that watches the player layer.

const GRAVITY := 950.0
const MAX_FALL := 330.0
const STOMP_MARGIN := 6.0 # how far above our top the player's feet may be

@export var max_hp := 1
@export var contact_damage := 1
var body_size := Vector2(16, 12)

var hp := 1
var facing := -1
var _flash := 0.0
var _stun := 0.0
var _dead := false
var _hurtbox: Area2D

func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = body_size
	shape.shape = rect
	shape.position = Vector2(0, -body_size.y / 2.0)
	add_child(shape)

	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = 0
	_hurtbox.collision_mask = 2
	var hshape := CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = body_size + Vector2(2, 2)
	hshape.shape = hrect
	hshape.position = shape.position
	_hurtbox.add_child(hshape)
	add_child(_hurtbox)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			modulate = Color.WHITE
	if _stun > 0.0:
		_stun -= delta
		velocity.x = 0.0
		_apply_gravity(delta)
		move_and_slide()
	else:
		_behave(delta)
	_check_contact()

func _behave(delta: float) -> void:
	_apply_gravity(delta)
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

func _check_contact() -> void:
	for body in _hurtbox.get_overlapping_bodies():
		if not body is Player:
			continue
		var p := body as Player
		if p.is_dashing():
			hurt(1, p.global_position)
		elif p.velocity.y > 0.0 and p.global_position.y <= global_position.y - body_size.y + STOMP_MARGIN:
			p.stomp_bounce()
			hurt(1, p.global_position)
		else:
			p.take_damage(contact_damage, global_position)

func hurt(amount: int, _from: Vector2) -> void:
	if _dead:
		return
	hp -= amount
	_flash = 0.1
	modulate = Color(3, 3, 3)
	if hp <= 0:
		_die()

func stun(seconds: float) -> void:
	_stun = maxf(_stun, seconds)

func _die() -> void:
	_dead = true
	collision_layer = 0
	_hurtbox.set_deferred("monitoring", false)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.4, 0.2), 0.12)
	tw.tween_callback(queue_free)

func _player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player
