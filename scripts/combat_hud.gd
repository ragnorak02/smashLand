extends Control

## Bottom-of-screen combat HUD showing damage percentage and stock icons per player.
## Also displays match timer top-center when time limit is active.

var fighters: Array = []
var damage_labels: Array[Label] = []
var stock_containers: Array[HBoxContainer] = []
var player_colors: Array[Color] = [Color(0.4, 0.7, 1.0), Color(1.0, 0.5, 0.4)]
var hide_p2: bool = false

# Timer display
var timer_label: Label
var match_time: float = 0.0
var show_timer: bool = false


func _ready() -> void:
	_build_hud()
	_build_timer()
	_build_controls_display()
	# Connect fighter signals after a frame to ensure fighters are ready
	_connect_signals.call_deferred()


func _process(_delta: float) -> void:
	if show_timer and timer_label:
		_update_timer_display()


func _connect_signals() -> void:
	for fighter in fighters:
		if fighter and is_instance_valid(fighter):
			fighter.damage_changed.connect(_on_damage_changed)
			fighter.stock_changed.connect(_on_stock_changed)


func _build_hud() -> void:
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hbox.offset_top = -130
	hbox.set("theme_override_constants/separation", 40)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hbox)

	var player_count := 1 if hide_p2 else 2
	for i in range(player_count):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(240, 90)

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.1, 0.15, 0.85)
		sb.set_content_margin_all(10)
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		sb.corner_radius_bottom_left = 8
		sb.corner_radius_bottom_right = 8
		sb.border_color = player_colors[i].darkened(0.3)
		sb.set_border_width_all(2)
		panel.add_theme_stylebox_override("panel", sb)
		hbox.add_child(panel)

		var vbox := VBoxContainer.new()
		vbox.set("theme_override_constants/separation", 4)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(vbox)

		# Player label
		var plabel := Label.new()
		plabel.text = "P%d" % (i + 1)
		plabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		plabel.add_theme_font_size_override("font_size", 14)
		plabel.add_theme_color_override("font_color", player_colors[i])
		vbox.add_child(plabel)

		# Damage percentage (large)
		var dmg := Label.new()
		dmg.text = "0%"
		dmg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dmg.add_theme_font_size_override("font_size", 36)
		dmg.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(dmg)
		damage_labels.append(dmg)

		# Stock icons
		var stock_box := HBoxContainer.new()
		stock_box.alignment = BoxContainer.ALIGNMENT_CENTER
		stock_box.set("theme_override_constants/separation", 6)
		vbox.add_child(stock_box)
		stock_containers.append(stock_box)

		# Build initial stock icons
		_rebuild_stocks(i, GameManager.stock_count)


func _build_timer() -> void:
	show_timer = GameManager.match_time_limit > 0 and not GameManager.training_mode
	if not show_timer:
		return

	timer_label = Label.new()
	timer_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	timer_label.offset_top = 16
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 36)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.custom_minimum_size = Vector2(120, 0)
	add_child(timer_label)


func set_match_time(time: float) -> void:
	match_time = time


func _update_timer_display() -> void:
	var t := int(ceil(match_time))
	if t < 0:
		t = 0
	var minutes := t / 60
	var seconds := t % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]

	# Color shifts: white (>60s) → yellow (≤60s) → red (≤10s)
	var color: Color
	if match_time > 60.0:
		color = Color.WHITE
	elif match_time > 10.0:
		var ratio := (match_time - 10.0) / 50.0
		color = Color(1.0, 0.2, 0.1).lerp(Color(1.0, 0.9, 0.2), ratio)
	else:
		color = Color(1.0, 0.2, 0.1)
	timer_label.add_theme_color_override("font_color", color)


func _on_damage_changed(pid: int, new_percent: float) -> void:
	var idx := pid - 1
	if idx < 0 or idx >= damage_labels.size():
		return
	damage_labels[idx].text = "%d%%" % int(new_percent)

	# Color shifts white → yellow → red as damage increases
	var t := clampf(new_percent / 150.0, 0.0, 1.0)
	var color: Color
	if t < 0.5:
		color = Color.WHITE.lerp(Color(1.0, 0.9, 0.2), t * 2.0)
	else:
		color = Color(1.0, 0.9, 0.2).lerp(Color(1.0, 0.2, 0.1), (t - 0.5) * 2.0)
	damage_labels[idx].add_theme_color_override("font_color", color)


func _on_stock_changed(pid: int, new_stocks: int) -> void:
	var idx := pid - 1
	if idx < 0 or idx >= stock_containers.size():
		return
	_rebuild_stocks(idx, new_stocks)


func _rebuild_stocks(player_idx: int, count: int) -> void:
	var container := stock_containers[player_idx]
	# Clear old icons
	for child in container.get_children():
		child.queue_free()
	# Add new stock icons
	for i in range(count):
		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(14, 14)
		icon.color = player_colors[player_idx]
		container.add_child(icon)


func _build_controls_display() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -30
	panel.custom_minimum_size = Vector2(0, 30)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.05, 0.08, 0.75)
	sb.set_content_margin_all(4)
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.set("theme_override_constants/separation", 18)
	panel.add_child(hbox)

	_add_control_entry(hbox, "LS", "Move")
	_add_control_entry(hbox, "A", "Jump")
	_add_control_entry(hbox, "X", "Attack")
	_add_control_entry(hbox, "B", "Special")
	_add_control_entry(hbox, "Y", "Grab")
	_add_control_entry(hbox, "LB", "Shield")
	_add_control_entry(hbox, "Start", "Pause")


func _add_control_entry(parent: HBoxContainer, button_text: String, action_text: String) -> void:
	var entry := HBoxContainer.new()
	entry.set("theme_override_constants/separation", 4)
	parent.add_child(entry)

	# Gold pill badge
	var badge := PanelContainer.new()
	var badge_sb := StyleBoxFlat.new()
	badge_sb.bg_color = Color(0.94, 0.78, 0.31)
	badge_sb.corner_radius_top_left = 4
	badge_sb.corner_radius_top_right = 4
	badge_sb.corner_radius_bottom_left = 4
	badge_sb.corner_radius_bottom_right = 4
	badge_sb.set_content_margin_all(2)
	badge_sb.content_margin_left = 5
	badge_sb.content_margin_right = 5
	badge.add_theme_stylebox_override("panel", badge_sb)
	entry.add_child(badge)

	var btn_label := Label.new()
	btn_label.text = button_text
	btn_label.add_theme_font_size_override("font_size", 11)
	btn_label.add_theme_color_override("font_color", Color(0.1, 0.08, 0.05))
	badge.add_child(btn_label)

	# Action text
	var act_label := Label.new()
	act_label.text = action_text
	act_label.add_theme_font_size_override("font_size", 12)
	act_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	entry.add_child(act_label)
