extends CanvasLayer
## Top-left counters plus the active zodiac power and today's season.

var _label: Label

func _ready() -> void:
	layer = 5
	_label = Label.new()
	_label.position = Vector2(8, 6)
	_label.add_theme_font_size_override("font_size", 12)
	add_child(_label)
	GameState.collected.connect(func(_k, _i): _refresh())
	GameState.loadout_changed.connect(_refresh)
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
