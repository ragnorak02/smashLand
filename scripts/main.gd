extends Control

## Main menu — New Game (training), Multiplayer Battle, Options, Exit.

const MENU_ITEMS := ["New Game", "Multiplayer Battle", "Options", "Exit"]

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

	# Confirm
	if Input.is_action_just_pressed("p1_select") or Input.is_action_just_pressed("p2_select"):
		_activate(selected)


func _activate(index: int) -> void:
	match index:
		0:  # New Game (training)
			GameManager.training_mode = true
			GameManager.change_scene("res://scenes/CharacterSelect.tscn")
		1:  # Multiplayer Battle
			GameManager.training_mode = false
			GameManager.change_scene("res://scenes/CharacterSelect.tscn")
		2:  # Options
			GameManager.change_scene("res://scenes/OptionsMenu.tscn")
		3:  # Exit
			get_tree().quit()


# ---- UI Construction ----

func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.1, 0.16)
	add_child(bg)

	# Root layout
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.set("theme_override_constants/separation", 12)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "SMASH LAND"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	root.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Platform Fighter"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	root.add_child(subtitle)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	root.add_child(spacer)

	# Menu items
	for i in range(MENU_ITEMS.size()):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(360, 56)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var label := Label.new()
		label.text = MENU_ITEMS[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		panel.add_child(label)

		root.add_child(panel)
		menu_panels.append(panel)

	# Footer
	var footer_spacer := Control.new()
	footer_spacer.custom_minimum_size = Vector2(0, 16)
	root.add_child(footer_spacer)

	var footer := Label.new()
	footer.text = "W/S or Arrows to navigate  |  SPACE or ENTER to select"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 14)
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
