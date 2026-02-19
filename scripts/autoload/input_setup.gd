extends Node

## Programmatically registers all input actions for both players.
## P1: Keyboard (WASD + Space) + Xbox Controller (device 0)
## P2: Arrow keys + Enter + Xbox Controller (device 0)


func _ready() -> void:
	_setup_player(1)
	_setup_player(2)
	_setup_pause()


func _setup_player(player: int) -> void:
	var p := "p%d_" % player

	var actions: Array[String] = ["move_left", "move_right", "move_up", "move_down", "jump", "select", "attack", "shield", "grab", "special"]
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
		_add_key(p + "attack", KEY_Q)
		_add_key(p + "shield", KEY_E)
		_add_key(p + "grab", KEY_R)
		_add_key(p + "special", KEY_F)
		# Xbox controller (device 0) — P1 gets controller too
		_add_joy_axis(p + "move_left", JOY_AXIS_LEFT_X, -1.0)
		_add_joy_axis(p + "move_right", JOY_AXIS_LEFT_X, 1.0)
		_add_joy_axis(p + "move_up", JOY_AXIS_LEFT_Y, -1.0)
		_add_joy_axis(p + "move_down", JOY_AXIS_LEFT_Y, 1.0)
		_add_joy_button(p + "jump", JOY_BUTTON_A)
		_add_joy_button(p + "select", JOY_BUTTON_A)
		_add_joy_button(p + "attack", JOY_BUTTON_X)
		_add_joy_button(p + "shield", JOY_BUTTON_LEFT_SHOULDER)
		_add_joy_button(p + "grab", JOY_BUTTON_Y)
		_add_joy_button(p + "special", JOY_BUTTON_B)
		_add_joy_button(p + "move_up", JOY_BUTTON_DPAD_UP)
		_add_joy_button(p + "move_down", JOY_BUTTON_DPAD_DOWN)
		_add_joy_button(p + "move_left", JOY_BUTTON_DPAD_LEFT)
		_add_joy_button(p + "move_right", JOY_BUTTON_DPAD_RIGHT)
	elif player == 2:
		# Arrow keys
		_add_key(p + "move_left", KEY_LEFT)
		_add_key(p + "move_right", KEY_RIGHT)
		_add_key(p + "move_up", KEY_UP)
		_add_key(p + "move_down", KEY_DOWN)
		_add_key(p + "jump", KEY_ENTER)
		_add_key(p + "select", KEY_ENTER)
		_add_key(p + "attack", KEY_SHIFT)  # Right Shift
		_add_key(p + "shield", KEY_CTRL)   # Right Ctrl
		_add_key(p + "grab", KEY_KP_0)     # Numpad 0
		_add_key(p + "special", KEY_KP_1)  # Numpad 1
		# Xbox controller (device 0)
		_add_joy_axis(p + "move_left", JOY_AXIS_LEFT_X, -1.0)
		_add_joy_axis(p + "move_right", JOY_AXIS_LEFT_X, 1.0)
		_add_joy_axis(p + "move_up", JOY_AXIS_LEFT_Y, -1.0)
		_add_joy_axis(p + "move_down", JOY_AXIS_LEFT_Y, 1.0)
		_add_joy_button(p + "jump", JOY_BUTTON_A)
		_add_joy_button(p + "select", JOY_BUTTON_A)
		_add_joy_button(p + "attack", JOY_BUTTON_X)
		_add_joy_button(p + "shield", JOY_BUTTON_LEFT_SHOULDER)
		_add_joy_button(p + "grab", JOY_BUTTON_Y)
		_add_joy_button(p + "special", JOY_BUTTON_B)
		# Xbox D-pad
		_add_joy_button(p + "move_up", JOY_BUTTON_DPAD_UP)
		_add_joy_button(p + "move_down", JOY_BUTTON_DPAD_DOWN)
		_add_joy_button(p + "move_left", JOY_BUTTON_DPAD_LEFT)
		_add_joy_button(p + "move_right", JOY_BUTTON_DPAD_RIGHT)


func _setup_pause() -> void:
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
	_add_key("pause", KEY_ESCAPE)
	_add_joy_button("pause", JOY_BUTTON_START)


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
