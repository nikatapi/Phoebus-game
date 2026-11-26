class_name Projectile
extends Area2D
## Enemy ember. Hurts Feebus, dies on walls, can be pecked out of the air.
## Layer 4 (value 8) so the player's peck query can find it.

const LIFETIME := 3.0

var velocity := Vector2.ZERO
var _age := 0.0

func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 2
	var shape := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 3.5
	shape.shape = c
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	_age += delta
	if _age > LIFETIME:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		(body as Player).take_damage(1, global_position)
	queue_free()

func hurt(_amount: int, _from: Vector2) -> void:
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color("ff9f1c"))
	draw_circle(Vector2.ZERO, 2.0, Color("fff3b0"))
