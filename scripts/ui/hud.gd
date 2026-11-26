extends CanvasLayer
## Top-left: hearts, then counters, active zodiac power and today's season.

var _label: Label
var _hearts: _Hearts

func _ready() -> void:
	layer = 5
	_hearts = _Hearts.new()
	_hearts.position = Vector2(10, 8)
	add_child(_hearts)

	_label = Label.new()
	_label.position = Vector2(8, 24)
	_label.add_theme_font_size_override("font_size", 12)
	add_child(_label)

	GameState.collected.connect(func(_k, _i): _refresh())
	GameState.loadout_changed.connect(_refresh)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.health_changed.connect(_hearts.set_hearts)
		_hearts.set_hearts(player.hearts, Player.MAX_HEARTS)
	_refresh()

func _refresh() -> void:
	var season := Zodiac.current_season()
	var slots := PackedStringArray()
	for i in GameState.LOADOUT_SLOTS:
		var n := Zodiac.display_name(GameState.equipped[i])
		slots.append("[%s]" % n if i == GameState.active_slot else n)
	_label.text = "Cartridges %d   Bobblebirds %d\nPower: %s\nSeason: %s" % [
		GameState.cartridges.size(), GameState.figures.size(),
		"  ".join(slots), Zodiac.display_name(season)]

class _Hearts extends Control:
	var hearts := 3
	var max_hearts := 3

	func set_hearts(h: int, m: int) -> void:
		hearts = h
		max_hearts = m
		queue_redraw()

	func _draw() -> void:
		for i in max_hearts:
			var c := Color("e63946") if i < hearts else Color(1, 1, 1, 0.25)
			var o := Vector2(i * 16, 0)
			draw_circle(o + Vector2(4, 4), 4.0, c)
			draw_circle(o + Vector2(10, 4), 4.0, c)
			draw_colored_polygon(PackedVector2Array([o + Vector2(0.5, 6), o + Vector2(13.5, 6), o + Vector2(7, 13)]), c)
