class_name Checkpoint
extends Area2D
## Perch flag. Touching it sets the respawn point and refills hearts.

var lit := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 32)
	shape.shape = rect
	shape.position = Vector2(0, -16)
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		var p := body as Player
		p.spawn_point = global_position + Vector2(0, -2)
		p.heal_full()
		if not lit:
			lit = true
			for cp in get_tree().get_nodes_in_group("checkpoint"):
				if cp != self:
					cp.set("lit", false)
					cp.queue_redraw()
			queue_redraw()

func _enter_tree() -> void:
	add_to_group("checkpoint")

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(0, -30), Color("8d6e63"), 2.0)   # perch post
	draw_line(Vector2(-6, -24), Vector2(6, -24), Color("8d6e63"), 2.0) # crossbar
	var col := Color("ffd60a") if lit else Color("6c757d")
	draw_colored_polygon(PackedVector2Array([Vector2(1, -30), Vector2(12, -26), Vector2(1, -22)]), col)
