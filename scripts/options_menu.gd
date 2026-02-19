extends Control

## Options menu — adjust stock count and match time limit, then return to main menu.

var stock_count: int = 3
var stock_label: Label

var time_options: Array[int] = [60, 120, 180, 240, 300, 420, 540, 0]  # seconds (0 = infinite)
var time_index: int = 4  # default 300s (5:00)
var time_label: Label

var selected_row: int = 0  # 0 = stocks, 1 = time
var row_panels: Array[PanelContainer] = []


func _ready() -> void:
	stock_count = GameManager.stock_count
	# Find current time limit in options array
	for i in range(time_options.size()):
		if time_options[i] == GameManager.match_time_limit:
			time_index = i
			break
	_build_ui()
	_update_stock_display()
	_update_time_display()
	_update_row_selection()


func _process(_delta: float) -> void:
	# Navigate between rows
	if Input.is_action_just_pressed("p1_move_up") or Input.is_action_just_pressed("p2_move_up"):
		selected_row = (selected_row - 1 + row_panels.size()) % row_panels.size()
		_update_row_selection()

	if Input.is_action_just_pressed("p1_move_down") or Input.is_action_just_pressed("p2_move_down"):
		selected_row = (selected_row + 1) % row_panels.size()
		_update_row_selection()

	# Adjust value left/right
	if Input.is_action_just_pressed("p1_move_left") or Input.is_action_just_pressed("p2_move_left"):
		if selected_row == 0:
			stock_count = max(1, stock_count - 1)
			_update_stock_display()
		else:
			time_index = max(0, time_index - 1)
			_update_time_display()

	if Input.is_action_just_pressed("p1_move_right") or Input.is_action_just_pressed("p2_move_right"):
		if selected_row == 0:
			stock_count = min(9, stock_count + 1)
			_update_stock_display()
		else:
			time_index = min(time_options.size() - 1, time_index + 1)
			_update_time_display()

	# Back to main menu
	if Input.is_action_just_pressed("p1_select") or Input.is_action_just_pressed("p2_select"):
		_save_and_return()

	if Input.is_action_just_pressed("p1_shield") or Input.is_action_just_pressed("ui_cancel"):
		_save_and_return()


func _save_and_return() -> void:
	GameManager.stock_count = stock_count
	GameManager.match_time_limit = time_options[time_index]
	GameManager.change_scene("res://scenes/Main.tscn")


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
	root.set("theme_override_constants/separation", 16)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "OPTIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	root.add_child(title)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	root.add_child(spacer)

	# Stock count card
	var stock_card := _build_setting_card(root, "Stock Count")
	stock_label = stock_card[1]
	row_panels.append(stock_card[0])

	# Spacer between cards
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 8)
	root.add_child(spacer2)

	# Match time card
	var time_card := _build_setting_card(root, "Match Time")
	time_label = time_card[1]
	row_panels.append(time_card[0])

	# Spacer
	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 16)
	root.add_child(spacer3)

	# Instructions
	var instr := Label.new()
	instr.text = "Up/Down to switch  |  Left/Right to adjust  |  SPACE/ENTER or E to confirm"
	instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instr.add_theme_font_size_override("font_size", 14)
	instr.add_theme_color_override("font_color", Color(0.4, 0.4, 0.48))
	root.add_child(instr)


func _build_setting_card(parent: VBoxContainer, label_text: String) -> Array:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(400, 80)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(card)

	var hbox := HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(hbox)

	var setting_label := Label.new()
	setting_label.text = label_text
	setting_label.add_theme_font_size_override("font_size", 22)
	setting_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	hbox.add_child(setting_label)

	var value_label := Label.new()
	value_label.text = "< ? >"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.add_theme_font_size_override("font_size", 26)
	value_label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	hbox.add_child(value_label)

	return [card, value_label]


func _update_stock_display() -> void:
	stock_label.text = "< %d >" % stock_count


func _update_time_display() -> void:
	var seconds: int = time_options[time_index]
	if seconds == 0:
		time_label.text = "< \u221e >"  # infinity symbol
	else:
		var m := seconds / 60
		var s := seconds % 60
		if s == 0:
			time_label.text = "< %d:00 >" % m
		else:
			time_label.text = "< %d:%02d >" % [m, s]


func _update_row_selection() -> void:
	for i in range(row_panels.size()):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.15, 0.18, 0.28, 0.9)
		sb.set_content_margin_all(14)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6

		if i == selected_row:
			sb.border_color = Color(0.94, 0.78, 0.31)
			sb.set_border_width_all(2)
		else:
			sb.border_color = Color(0.3, 0.3, 0.38)
			sb.set_border_width_all(1)

		row_panels[i].add_theme_stylebox_override("panel", sb)
