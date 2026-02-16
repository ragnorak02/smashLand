extends Control

## Persistent on-screen debug HUD showing input state per player.

var fighters: Array = []
var labels: Dictionary = {}


func _ready() -> void:
	_build_hud()


func _build_hud() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(10, 10)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.65)
	sb.set_content_margin_all(8)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set("theme_override_constants/separation", 2)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "INPUT DEBUG"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(title)

	for i in range(2):
		var pn := i + 1
		var prefix := "p%d_" % pn

		var header := Label.new()
		header.text = "-- P%d --" % pn
		header.add_theme_font_size_override("font_size", 10)
		header.add_theme_color_override("font_color",
			Color(0.5, 0.7, 1.0) if pn == 1 else Color(1.0, 0.5, 0.4))
		vbox.add_child(header)

		for key in ["move", "jump", "state", "method"]:
			var lbl := Label.new()
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
			vbox.add_child(lbl)
			labels[prefix + key] = lbl


func _process(_delta: float) -> void:
	for i in range(mini(fighters.size(), 2)):
		var pn := i + 1
		var prefix := "p%d_" % pn
		var fighter = fighters[i]

		# Movement axes
		var h := Input.get_axis(prefix + "move_left", prefix + "move_right")
		var v := Input.get_axis(prefix + "move_up", prefix + "move_down")
		labels[prefix + "move"].text = "Move: H=%.1f  V=%.1f" % [h, v]

		# Jump
		var jp := Input.is_action_pressed(prefix + "jump")
		var jl: int = fighter.jumps_remaining if fighter else 0
		labels[prefix + "jump"].text = "Jump: %s  Left: %d" % ["HELD" if jp else "----", jl]

		# State
		var on_floor: bool = fighter.is_on_floor() if fighter else false
		var vel: Vector2 = fighter.velocity if fighter else Vector2.ZERO
		labels[prefix + "state"].text = "Floor:%s  Vel:(%d,%d)" % [
			"Y" if on_floor else "N", int(vel.x), int(vel.y)]

		# Input method
		labels[prefix + "method"].text = "Input: %s" % _detect_method(pn)


func _detect_method(player: int) -> String:
	if player == 1:
		return "Keyboard"
	var pads := Input.get_connected_joypads()
	return "Controller" if pads.size() > 0 else "Keyboard"
