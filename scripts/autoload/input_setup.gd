extends Node
## Defines input actions in code so the bindings live in version control
## in a readable form. Touch buttons trigger the same actions.

const KEYS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE, KEY_Z, KEY_W, KEY_UP],
	"attack": [KEY_X, KEY_J],
	"power": [KEY_C, KEY_K],
	"swap_power": [KEY_V, KEY_L],
	"pause": [KEY_ESCAPE, KEY_P],
}

const PAD_BUTTONS := {
	"jump": [JOY_BUTTON_A],
	"attack": [JOY_BUTTON_X],
	"power": [JOY_BUTTON_B],
	"swap_power": [JOY_BUTTON_Y, JOY_BUTTON_RIGHT_SHOULDER],
	"pause": [JOY_BUTTON_START],
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"move_down": [JOY_BUTTON_DPAD_DOWN],
}

func _ready() -> void:
	for action in KEYS:
		_ensure(action)
		for key in KEYS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
	for action in PAD_BUTTONS:
		_ensure(action)
		for b in PAD_BUTTONS[action]:
			var ev := InputEventJoypadButton.new()
			ev.button_index = b
			InputMap.action_add_event(action, ev)
	_add_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)

func _ensure(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.3)

func _add_axis(action: String, axis: JoyAxis, value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	InputMap.action_add_event(action, ev)
