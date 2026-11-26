extends Node
## Persistent progress: collections, unlocked and equipped zodiac signs,
## birth sign. Saved as JSON in user://.

signal collected(kind: String, id: String)
signal loadout_changed

const SAVE_PATH := "user://save.json"
const LOADOUT_SLOTS := 2

var birth_sign := ""
var unlocked_signs: Array[String] = []
var equipped: Array[String] = ["", ""]
var active_slot := 0
var cartridges: Array[String] = []
var figures: Array[String] = []

func _ready() -> void:
	load_game()

# --- Collection -------------------------------------------------------------

func has_item(kind: String, id: String) -> bool:
	match kind:
		"cartridge": return id in cartridges
		"figure": return id in figures
		"zodiac": return id in unlocked_signs
	return false

func collect(kind: String, id: String) -> void:
	if has_item(kind, id):
		return
	match kind:
		"cartridge": cartridges.append(id)
		"figure": figures.append(id)
		"zodiac": unlock_sign(id)
	collected.emit(kind, id)
	save_game()

# --- Zodiac loadout ---------------------------------------------------------

func unlock_sign(id: String) -> void:
	if id in unlocked_signs:
		return
	unlocked_signs.append(id)
	# Auto-equip into the first empty slot so a new power is usable immediately.
	for i in LOADOUT_SLOTS:
		if equipped[i] == "":
			equipped[i] = id
			active_slot = i
			break
	loadout_changed.emit()

func equip(slot: int, id: String) -> void:
	if id != "" and id not in unlocked_signs:
		return
	equipped[slot] = id
	loadout_changed.emit()
	save_game()

func active_sign() -> String:
	return equipped[active_slot]

func swap_active() -> void:
	active_slot = (active_slot + 1) % LOADOUT_SLOTS
	loadout_changed.emit()

## Season bonus: the real-world zodiac season boosts that sign's power.
func is_in_season(id: String) -> bool:
	return id != "" and id == Zodiac.current_season()

## Birth-sign bonus: a small passive picked once at first launch.
func is_birth_sign(id: String) -> bool:
	return id != "" and id == birth_sign

# --- Save / load ------------------------------------------------------------

func save_game() -> void:
	var data := {
		"version": 1,
		"birth_sign": birth_sign,
		"unlocked_signs": unlocked_signs,
		"equipped": equipped,
		"cartridges": cartridges,
		"figures": figures,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	birth_sign = data.get("birth_sign", "")
	unlocked_signs.assign(data.get("unlocked_signs", []))
	equipped.assign(data.get("equipped", ["", ""]))
	while equipped.size() < LOADOUT_SLOTS:
		equipped.append("")
	cartridges.assign(data.get("cartridges", []))
	figures.assign(data.get("figures", []))

func reset_progress() -> void:
	birth_sign = ""
	unlocked_signs.clear()
	equipped.assign(["", ""])
	active_slot = 0
	cartridges.clear()
	figures.clear()
	save_game()
	loadout_changed.emit()
