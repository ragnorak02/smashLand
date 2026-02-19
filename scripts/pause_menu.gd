extends Control

## Pause menu overlay — Resume, Restart, Quit with Up/Down navigation.
## Spawned by arena.gd as a CanvasLayer child at layer 100.

const MENU_ITEMS := ["Resume", "Restart", "Quit"]

var selected: int = 0
var menu_panels: Array[PanelContainer] = []


func _ready() -> void:
	_build_ui()
	_update_selection()


func _process(_delta: float) -> void:
	# Navigate up
	if Input.is_action_just_pressed("p1_move_up") or Input.is_action_just_pressed("p2_move_up"):
		selected = (selected - 1 + MENU_ITEMS.size()) % MENU_ITEMS.size()
		_update_selection()

	# Navigate down
	if Input.is_action_just_pressed("p1_move_down") or Input.is_action_just_pressed("p2_move_down"):
		selected = (selected + 1) % MENU_ITEMS.size()
		_update_selection()

	# Confirm selection
	if Input.is_action_just_pressed("p1_select") or Input.is_action_just_pressed("p2_select"):
		_activate(selected)

	# ESC / Start = resume (same as selecting Resume)
	if Input.is_action_just_pressed("pause"):
		_activate(0)


func _activate(index: int) -> void:
	match index:
		0:  # Resume
			_resume()
		1:  # Restart
			GameManager.is_paused = false
			GameManager.change_scene("res://scenes/CharacterSelect.tscn")
		2:  # Quit
			GameManager.is_paused = false
			GameManager.change_scene("res://scenes/Main.tscn")


func _resume() -> void:
	GameManager.is_paused = false
	# Remove the pause CanvasLayer (our parent)
	var canvas := get_parent()
	if canvas:
		canvas.get_parent().remove_child(canvas)
		canvas.queue_free()


# ---- UI Construction ----

func _build_ui() -> void:
	# Dark overlay background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	add_child(bg)

	# Root layout
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.set("theme_override_constants/separation", 12)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	root.add_child(title)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	root.add_child(spacer)

	# Menu items
	for i in range(MENU_ITEMS.size()):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(320, 52)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var label := Label.new()
		label.text = MENU_ITEMS[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		panel.add_child(label)

		root.add_child(panel)
		menu_panels.append(panel)

	# Footer hint
	var footer_spacer := Control.new()
	footer_spacer.custom_minimum_size = Vector2(0, 12)
	root.add_child(footer_spacer)

	var footer := Label.new()
	footer.text = "W/S or Arrows to navigate  |  SPACE/ENTER to select  |  ESC to resume"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color(0.4, 0.4, 0.48))
	root.add_child(footer)


# ---- Selection Display ----

func _update_selection() -> void:
	for i in range(menu_panels.size()):
		var sb := StyleBoxFlat.new()
		sb.set_content_margin_all(12)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6

		var label: Label = menu_panels[i].get_child(0)

		if i == selected:
			sb.bg_color = Color(0.15, 0.18, 0.28, 0.9)
			sb.border_color = Color(0.94, 0.78, 0.31)
			sb.set_border_width_all(3)
			label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
		else:
			sb.bg_color = Color(0.12, 0.14, 0.2, 0.6)
			sb.border_color = Color(0.25, 0.25, 0.3)
			sb.set_border_width_all(1)
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))

		menu_panels[i].add_theme_stylebox_override("panel", sb)
