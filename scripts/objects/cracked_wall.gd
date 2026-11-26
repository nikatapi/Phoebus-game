class_name CrackedWall
extends StaticBody2D
## Breakable by Aries Ram Dash (the player calls smash()).

var size := Vector2(16, 48)

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = size / 2.0
	add_child(shape)

func smash() -> void:
	queue_free()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("8d6e63"))
	draw_line(Vector2(4, 4), Vector2(12, 20), Color("3e2723"), 1.0)
	draw_line(Vector2(12, 20), Vector2(5, 34), Color("3e2723"), 1.0)
	draw_line(Vector2(5, 34), Vector2(11, 44), Color("3e2723"), 1.0)
