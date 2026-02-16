extends Node

## Programmatically registers all input actions for both players.
## P1: Keyboard (WASD + Space)
## P2: Arrow keys + Enter / Xbox Controller


func _ready() -> void:
	_setup_player(1)
	_setup_player(2)


func _setup_player(player: int) -> void:
	var p := "p%d_" % player

	var actions: Array[String] = ["move_left", "move_right", "move_up", "move_down", "jump", "select"]
	for action in actions:
		var full: String = p + action
		if not InputMap.has_action(full):
			InputMap.add_action(full)
			InputMap.action_set_deadzone(full, 0.3)

	if player == 1:
		_add_key(p + "move_left", KEY_A)
		_add_key(p + "move_right", KEY_D)
		_add_key(p + "move_up", KEY_W)
		_add_key(p + "move_down", KEY_S)
		_add_key(p + "jump", KEY_SPACE)
		_add_key(p + "select", KEY_SPACE)
	elif player == 2:
		# Arrow keys
		_add_key(p + "move_left", KEY_LEFT)
		_add_key(p + "move_right", KEY_RIGHT)
		_add_key(p + "move_up", KEY_UP)
		_add_key(p + "move_down", KEY_DOWN)
		_add_key(p + "jump", KEY_ENTER)
		_add_key(p + "select", KEY_ENTER)
		# Xbox controller (device 0)
		_add_joy_axis(p + "move_left", JOY_AXIS_LEFT_X, -1.0)
		_add_joy_axis(p + "move_right", JOY_AXIS_LEFT_X, 1.0)
		_add_joy_axis(p + "move_up", JOY_AXIS_LEFT_Y, -1.0)
		_add_joy_axis(p + "move_down", JOY_AXIS_LEFT_Y, 1.0)
		_add_joy_button(p + "jump", JOY_BUTTON_A)
		_add_joy_button(p + "select", JOY_BUTTON_A)


func _add_key(action: String, keycode: Key) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	InputMap.action_add_event(action, ev)


func _add_joy_button(action: String, button: JoyButton) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = 0
	ev.button_index = button
	InputMap.action_add_event(action, ev)


func _add_joy_axis(action: String, axis: JoyAxis, value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = axis
	ev.axis_value = value
	InputMap.action_add_event(action, ev)
