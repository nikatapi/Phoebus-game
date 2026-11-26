extends Node2D
## Builds a greybox level from data so layouts can be iterated as text.
## Real levels will move to TileMapLayer once art exists.

const TILE := Color("6d4c41")
const TOP := Color("ff7f11")

## Solid platforms: Rect2(x, y, width, height). Fire world palette.
@export var platforms: Array[Rect2] = [
	Rect2(-200, 0, 600, 200),
	Rect2(480, 0, 300, 200),     # after first gap
	Rect2(560, -70, 80, 12),
	Rect2(700, -130, 80, 12),
	Rect2(860, 0, 500, 200),     # after wide gap (needs flutter)
	Rect2(1100, -200, 16, 152),  # tall wall; the bottom 48px is a CrackedWall
	Rect2(1450, 0, 400, 200),
]

## Pickups: [kind, id, position].
@export var pickups: Array = [
	["zodiac", "aries", Vector2(620, -100)],
	["cartridge", "cart_lava_blaster", Vector2(1250, -30)],
	["figure", "bb_ember_slug", Vector2(740, -160)],
	["figure", "bb_kiln_crab", Vector2(1700, -40)],
]

## Enemies: [type, position on the ground]. Types: "walker", "shooter".
@export var enemies: Array = [
	["walker", Vector2(250, 0)],
	["walker", Vector2(650, 0)],
	["shooter", Vector2(1020, 0)],
	["walker", Vector2(1250, 0)],
	["shooter", Vector2(1780, 0)],
	["walker", Vector2(1600, 0)],
]

## Checkpoint perches: ground positions.
@export var checkpoints: Array[Vector2] = [Vector2(520, 0), Vector2(1480, 0)]

## Breakable walls: top-left positions.
@export var cracked_walls: Array[Vector2] = [Vector2(1100, -48)]

@export var spawn := Vector2(0, -20)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("2b1a1a"))
	for r in platforms:
		_add_platform(r)
	for w in cracked_walls:
		var wall := CrackedWall.new()
		wall.position = w
		add_child(wall)
	for cp_pos in checkpoints:
		var cp := Checkpoint.new()
		cp.position = cp_pos
		add_child(cp)
	for e in enemies:
		var enemy: Enemy
		if e[0] == "walker":
			enemy = Walker.new()
		else:
			enemy = Shooter.new()
		enemy.position = e[1]
		add_child(enemy)
	for p in pickups:
		var c := Collectible.new()
		c.kind = p[0]
		c.item_id = p[1]
		c.position = p[2]
		add_child(c)
	var player: Player = $Player
	player.global_position = spawn
	player.spawn_point = spawn

func _add_platform(r: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = r.position
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = r.size
	shape.shape = rect
	shape.position = r.size / 2.0
	body.add_child(shape)
	var fill := ColorRect.new()
	fill.size = r.size
	fill.color = TILE
	body.add_child(fill)
	var top := ColorRect.new()
	top.size = Vector2(r.size.x, 3)
	top.color = TOP
	body.add_child(top)
	add_child(body)
