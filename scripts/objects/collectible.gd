class_name Collectible
extends Area2D
## A pickup: "cartridge", "figure" (Bobblebird) or "zodiac" (sign shrine).
## Already-collected items do not respawn.

@export_enum("cartridge", "figure", "zodiac") var kind := "cartridge"
@export var item_id := ""

var _t := 0.0

func _ready() -> void:
	if GameState.has_item(kind, item_id):
		queue_free()
		return
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_t += delta
	position.y += sin(_t * 3.0) * 0.15 # gentle bob
	if kind == "zodiac":
		queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameState.collect(kind, item_id)
		queue_free()

func _draw() -> void:
	match kind:
		"cartridge":
			draw_rect(Rect2(-7, -8, 14, 16), Color("5a5a66"))
			draw_rect(Rect2(-5, -6, 10, 7), Color("e63946"))
			draw_rect(Rect2(-6, 5, 12, 3), Color("2b2d42"))
		"figure":
			draw_rect(Rect2(-4, -2, 8, 9), Color("4361ee"))   # body
			draw_circle(Vector2(0, -7), 6.0, Color("ffd6a5")) # big head
			draw_circle(Vector2(-2, -7), 1.2, Color.BLACK)
			draw_circle(Vector2(2, -7), 1.2, Color.BLACK)
		"zodiac":
			var glow := 0.6 + 0.4 * sin(_t * 4.0)
			draw_circle(Vector2.ZERO, 11.0, Color(1.0, 0.55, 0.1, 0.35 * glow))
			draw_circle(Vector2.ZERO, 7.0, Color("ff9f1c"))
			draw_string(ThemeDB.fallback_font, Vector2(-4, 4), item_id.substr(0, 1).to_upper(),
				HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)
