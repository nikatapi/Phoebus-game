extends CanvasLayer
## On-screen buttons, visible only on touchscreens. Each button fires a
## regular input action, so gameplay code never knows about touch.
## Layout: left/right on the left thumb; jump, attack, power on the right;
## small swap button above power.

const BASE := Vector2(640, 360) # viewport size from project settings

const LAYOUT := [
	# [action, label, center, radius]
	["move_left", "<", Vector2(56, 300), 34.0],
	["move_right", ">", Vector2(140, 300), 34.0],
	["jump", "J", Vector2(584, 296), 38.0],
	["attack", "A", Vector2(500, 316), 28.0],
	["power", "P", Vector2(520, 236), 28.0],
	["swap_power", "S", Vector2(590, 200), 18.0],
]

func _ready() -> void:
	layer = 10
	for b in LAYOUT:
		add_child(_make_button(b[0], b[1], b[2], b[3]))

func _make_button(action: String, label: String, center: Vector2, radius: float) -> TouchScreenButton:
	var btn := TouchScreenButton.new()
	btn.action = action
	btn.position = center
	btn.passby_press = action.begins_with("move_") # slide thumb between left/right
	btn.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
	var circle := CircleShape2D.new()
	circle.radius = radius * 1.25 # hit area larger than the drawn button
	btn.shape = circle
	btn.shape_centered = true
	var art := _ButtonArt.new()
	art.radius = radius
	art.label = label
	btn.add_child(art)
	btn.pressed.connect(art.set_pressed.bind(true))
	btn.released.connect(art.set_pressed.bind(false))
	return btn

class _ButtonArt extends Node2D:
	var radius := 30.0
	var label := ""
	var _pressed := false

	func set_pressed(v: bool) -> void:
		_pressed = v
		queue_redraw()

	func _draw() -> void:
		var a := 0.55 if _pressed else 0.28
		draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, a))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1, 1, 1, 0.6), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-radius, 6), label,
			HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 18, Color(1, 1, 1, 0.9))
