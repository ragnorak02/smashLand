extends Control

## Bottom-of-screen combat HUD showing damage percentage and stock icons per player.

var fighters: Array = []
var damage_labels: Array[Label] = []
var stock_containers: Array[HBoxContainer] = []
var player_colors: Array[Color] = [Color(0.4, 0.7, 1.0), Color(1.0, 0.5, 0.4)]
var hide_p2: bool = false


func _ready() -> void:
	_build_hud()
	# Connect fighter signals after a frame to ensure fighters are ready
	_connect_signals.call_deferred()


func _connect_signals() -> void:
	for fighter in fighters:
		if fighter and is_instance_valid(fighter):
			fighter.damage_changed.connect(_on_damage_changed)
			fighter.stock_changed.connect(_on_stock_changed)


func _build_hud() -> void:
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hbox.offset_top = -100
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
