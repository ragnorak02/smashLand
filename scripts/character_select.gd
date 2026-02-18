extends Control

## Character selection screen. Each player picks a fighter, then the arena loads.
## In training mode, only P1 selects; P2 is auto-readied.

const FIGHTER_NAMES := ["Brawler", "Speedster"]
const FIGHTER_COLORS: Array[Color] = [Color(0.2, 0.4, 0.9), Color(0.9, 0.2, 0.2)]
const FIGHTER_DESCS := ["Powerful jumps, solid ground game", "Fast movement, extra air jumps"]

var p1_selection: int = 0
var p2_selection: int = 1
var p1_ready: bool = false
var p2_ready: bool = false
var transitioning: bool = false
var transition_timer: float = 0.0

# UI references (built in _ready)
var title_label: Label
var p1_options: Array[PanelContainer] = []
var p2_options: Array[PanelContainer] = []
var p1_ready_label: Label
var p2_ready_label: Label


func _ready() -> void:
	if GameManager.training_mode:
		p2_ready = true
	_build_ui()
	_update_display()


func _process(delta: float) -> void:
	if transitioning:
		transition_timer -= delta
		if transition_timer <= 0.0:
			GameManager.player1_character = p1_selection
			GameManager.player2_character = p2_selection
			GameManager.change_scene("res://scenes/Arena.tscn")
		return

	# Back to main menu (E key / LB)
	if Input.is_action_just_pressed("p1_shield"):
		GameManager.change_scene("res://scenes/Main.tscn")
		return

	# P1 input
	if not p1_ready:
		if Input.is_action_just_pressed("p1_move_up") or Input.is_action_just_pressed("p1_move_down"):
			p1_selection = 1 - p1_selection
			_update_display()
		if Input.is_action_just_pressed("p1_select"):
			p1_ready = true
			_update_display()
	else:
		# Allow un-ready with movement
		if Input.is_action_just_pressed("p1_move_up") or Input.is_action_just_pressed("p1_move_down"):
			p1_ready = false
			p1_selection = 1 - p1_selection
			_update_display()

	# P2 input (skip in training mode)
	if not GameManager.training_mode:
		if not p2_ready:
			if Input.is_action_just_pressed("p2_move_up") or Input.is_action_just_pressed("p2_move_down"):
				p2_selection = 1 - p2_selection
				_update_display()
			if Input.is_action_just_pressed("p2_select"):
				p2_ready = true
				_update_display()
		else:
			if Input.is_action_just_pressed("p2_move_up") or Input.is_action_just_pressed("p2_move_down"):
				p2_ready = false
				p2_selection = 1 - p2_selection
				_update_display()

	# Both ready — start match
	if p1_ready and p2_ready and not transitioning:
		transitioning = true
		transition_timer = 0.8
		title_label.text = "GET READY!"
		title_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))


# ---- UI Construction ----

func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.12, 0.18)
	add_child(bg)

	# Root layout
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.set("theme_override_constants/separation", 16)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# Title
	title_label = Label.new()
	title_label.text = "CHOOSE YOUR FIGHTER"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 40)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	root.add_child(title_label)

	# Training mode subtitle
	if GameManager.training_mode:
		var training_sub := Label.new()
		training_sub.text = "TRAINING MODE"
		training_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		training_sub.add_theme_font_size_override("font_size", 18)
		training_sub.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
		root.add_child(training_sub)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	root.add_child(spacer)

	# Player columns
	var columns := HBoxContainer.new()
	columns.set("theme_override_constants/separation", 60)
	columns.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(columns)

	_build_player_column(1, columns)

	if not GameManager.training_mode:
		# Divider
		var divider := VSeparator.new()
		divider.custom_minimum_size = Vector2(2, 0)
		columns.add_child(divider)

		_build_player_column(2, columns)

	# Instructions
	var instr := Label.new()
	if GameManager.training_mode:
		instr.text = "P1: W/S + SPACE  |  E to go back"
	else:
		instr.text = "P1: W/S + SPACE   |   P2: Arrows + ENTER  /  Controller   |   E to go back"
	instr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instr.add_theme_font_size_override("font_size", 15)
	instr.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	root.add_child(instr)


func _build_player_column(player: int, parent: Control) -> void:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(380, 0)
	col.set("theme_override_constants/separation", 10)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(col)

	# Header
	var header := Label.new()
	header.text = "PLAYER %d" % player
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 26)
	header.add_theme_color_override("font_color",
		Color(0.4, 0.65, 1.0) if player == 1 else Color(1.0, 0.5, 0.4))
	col.add_child(header)

	# Control method subtitle
	var sub := Label.new()
	sub.text = "[WASD + SPACE]" if player == 1 else "[Arrows + ENTER / Controller]"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
	col.add_child(sub)

	# Fighter option cards
	var options_ref := p1_options if player == 1 else p2_options
	for i in range(FIGHTER_NAMES.size()):
		var card := _build_fighter_card(i)
		col.add_child(card)
		options_ref.append(card)

	# Ready label
	var ready := Label.new()
	ready.text = ""
	ready.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ready.add_theme_font_size_override("font_size", 22)
	ready.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	col.add_child(ready)

	if player == 1:
		p1_ready_label = ready
	else:
		p2_ready_label = ready


func _build_fighter_card(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 80)

	var hbox := HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 14)
	panel.add_child(hbox)

	# Color swatch
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(50, 60)
	swatch.color = FIGHTER_COLORS[index]
	hbox.add_child(swatch)

	# Info
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_label := Label.new()
	name_label.text = FIGHTER_NAMES[index]
	name_label.add_theme_font_size_override("font_size", 20)
	info.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = FIGHTER_DESCS[index]
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	info.add_child(desc_label)

	return panel


# ---- Display Update ----

func _update_display() -> void:
	_style_options(p1_options, p1_selection, Color(0.2, 0.3, 0.55), Color(0.4, 0.6, 1.0))
	if not GameManager.training_mode:
		_style_options(p2_options, p2_selection, Color(0.5, 0.2, 0.2), Color(1.0, 0.5, 0.4))
	p1_ready_label.text = "READY!" if p1_ready else ""
	if not GameManager.training_mode:
		p2_ready_label.text = "READY!" if p2_ready else ""


func _style_options(options: Array[PanelContainer], selected: int, sel_bg: Color, sel_border: Color) -> void:
	for i in range(options.size()):
		var sb := StyleBoxFlat.new()
		if i == selected:
			sb.bg_color = Color(sel_bg.r, sel_bg.g, sel_bg.b, 0.85)
			sb.border_color = sel_border
			sb.set_border_width_all(3)
		else:
			sb.bg_color = Color(0.15, 0.17, 0.22, 0.5)
			sb.border_color = Color(0.3, 0.3, 0.35)
			sb.set_border_width_all(1)
		sb.set_content_margin_all(10)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		options[i].add_theme_stylebox_override("panel", sb)
