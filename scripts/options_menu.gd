extends Control

## Options menu — adjust stock count, then return to main menu.

var stock_count: int = 3
var stock_label: Label


func _ready() -> void:
	stock_count = GameManager.stock_count
	_build_ui()
	_update_stock_display()


func _process(_delta: float) -> void:
	# Adjust stock count left/right
	if Input.is_action_just_pressed("p1_move_left") or Input.is_action_just_pressed("p2_move_left"):
		stock_count = max(1, stock_count - 1)
		_update_stock_display()

	if Input.is_action_just_pressed("p1_move_right") or Input.is_action_just_pressed("p2_move_right"):
		stock_count = min(9, stock_count + 1)
		_update_stock_display()

	# Back to main menu
	if Input.is_action_just_pressed("p1_select") or Input.is_action_just_pressed("p2_select"):
		_save_and_return()

	if Input.is_action_just_pressed("p1_shield") or Input.is_action_just_pressed("ui_cancel"):
		_save_and_return()


func _save_and_return() -> void:
	GameManager.stock_count = stock_count
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
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(400, 80)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.18, 0.28, 0.9)
	sb.border_color = Color(0.94, 0.78, 0.31)
	sb.set_border_width_all(2)
	sb.set_content_margin_all(14)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", sb)
	root.add_child(card)

	var hbox := HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(hbox)

	var setting_label := Label.new()
	setting_label.text = "Stock Count"
	setting_label.add_theme_font_size_override("font_size", 22)
	setting_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	hbox.add_child(setting_label)

	stock_label = Label.new()
	stock_label.text = "< 3 >"
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stock_label.custom_minimum_size = Vector2(80, 0)
	stock_label.add_theme_font_size_override("font_size", 26)
	stock_label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	hbox.add_child(stock_label)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 16)
	root.add_child(spacer2)

	# Instructions
	var instr := Label.new()
	instr.text = "Left/Right to adjust  |  SPACE/ENTER or E to confirm"
	instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instr.add_theme_font_size_override("font_size", 14)
	instr.add_theme_color_override("font_color", Color(0.4, 0.4, 0.48))
	root.add_child(instr)


func _update_stock_display() -> void:
	stock_label.text = "< %d >" % stock_count
