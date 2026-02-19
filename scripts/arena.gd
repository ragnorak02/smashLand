extends Node2D

## Arena manager — builds the stage, spawns fighters, sets up camera, combat HUD, and game flow.
## Supports training mode (single fighter, no match end, E+R to exit).
## Includes match timer countdown and pause menu.

const FighterScene := preload("res://scenes/FighterBase.tscn")

var fighters: Array = []
var dynamic_camera: Camera2D
var match_over: bool = false
var return_timer: float = 0.0
var platform_data: Array[Dictionary] = []

# Match timer
var match_time: float = 0.0
var combat_hud: Control

# Pause menu
var pause_canvas: CanvasLayer


func _ready() -> void:
	match_time = float(GameManager.match_time_limit)
	_build_stage()
	# Wait two physics frames so the physics server fully registers platform collision shapes
	await get_tree().physics_frame
	await get_tree().physics_frame
	_spawn_fighters()
	_setup_camera()
	_setup_combat_hud()
	_setup_minimap()
	if GameManager.training_mode:
		_setup_training_overlay()
	print("[Arena] Init complete on frame %d — %d fighters spawned" % [Engine.get_physics_frames(), fighters.size()])


func _process(delta: float) -> void:
	# Training mode exit: E+R combo
	if GameManager.training_mode:
		if Input.is_action_pressed("p1_shield") and Input.is_action_pressed("p1_grab"):
			GameManager.change_scene("res://scenes/Main.tscn")
			return

	# Pause toggle (not in training mode or after match ends)
	if Input.is_action_just_pressed("pause") and not match_over and not GameManager.training_mode:
		_toggle_pause()
		return

	# Skip all logic while paused
	if GameManager.is_paused:
		return

	# Match timer countdown
	if not match_over and not GameManager.training_mode and GameManager.match_time_limit > 0:
		match_time -= delta
		if combat_hud and combat_hud.has_method("set_match_time"):
			combat_hud.set_match_time(match_time)
		if match_time <= 0.0:
			match_time = 0.0
			_time_up()

	if match_over:
		return_timer -= delta
		if return_timer <= 0.0:
			GameManager.change_scene("res://scenes/Main.tscn")


# --- Pause ---

func _toggle_pause() -> void:
	if GameManager.is_paused:
		# Unpause — remove pause menu
		GameManager.is_paused = false
		if pause_canvas and is_instance_valid(pause_canvas):
			remove_child(pause_canvas)
			pause_canvas.queue_free()
			pause_canvas = null
	else:
		# Pause — show pause menu
		GameManager.is_paused = true
		_setup_pause_menu()


func _setup_pause_menu() -> void:
	var pm_script := load("res://scripts/pause_menu.gd")
	pause_canvas = CanvasLayer.new()
	pause_canvas.name = "PauseMenuLayer"
	pause_canvas.layer = 100

	var pm := Control.new()
	pm.set_script(pm_script)
	pm.name = "PauseMenu"
	pm.set_anchors_preset(Control.PRESET_FULL_RECT)

	pause_canvas.add_child(pm)
	add_child(pause_canvas)


# --- Stage Construction ---

func _build_stage() -> void:
	# Main platform
	_add_platform(Vector2(0, 0), Vector2(900, 40), Color(0.32, 0.52, 0.28))

	# Small floating side platforms
	_add_platform(Vector2(-480, -130), Vector2(200, 18), Color(0.38, 0.58, 0.32))
	_add_platform(Vector2(480, -130), Vector2(200, 18), Color(0.38, 0.58, 0.32))

	# Visual: stage underside shadow
	var shadow := ColorRect.new()
	shadow.size = Vector2(900, 120)
	shadow.position = Vector2(-450, 20)
	shadow.color = Color(0.08, 0.1, 0.14, 0.6)
	add_child(shadow)


func _add_platform(pos: Vector2, size: Vector2, color: Color) -> void:
	platform_data.append({"pos": pos, "size": size})
	var body := StaticBody2D.new()
	body.position = pos

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)

	# Platform surface
	var surface := ColorRect.new()
	surface.size = size
	surface.position = Vector2(-size.x / 2.0, -size.y / 2.0)
	surface.color = color
	body.add_child(surface)

	# Top edge highlight
	var edge := ColorRect.new()
	edge.size = Vector2(size.x, 3)
	edge.position = Vector2(-size.x / 2.0, -size.y / 2.0)
	edge.color = color.lightened(0.4)
	body.add_child(edge)

	add_child(body)


# --- Fighter Spawning ---

func _spawn_fighters() -> void:
	if GameManager.training_mode:
		# Training mode: spawn only P1
		var fighter = FighterScene.instantiate()
		fighter.set("player_id", 1)
		fighter.set("fighter_type", GameManager.player1_character)
		fighter.set("stocks", GameManager.stock_count)
		fighter.position = Vector2(0, -30)
		add_child(fighter)
		fighters.append(fighter)
		print("[Arena] Training fighter spawned at %s on frame %d" % [fighter.position, Engine.get_physics_frames()])
	else:
		# Normal 2P match
		var spawns: Array[Vector2] = [Vector2(-200, -30), Vector2(200, -30)]
		var characters: Array[int] = [GameManager.player1_character, GameManager.player2_character]

		for i in range(2):
			var fighter = FighterScene.instantiate()
			fighter.set("player_id", i + 1)
			fighter.set("fighter_type", characters[i])
			fighter.set("stocks", GameManager.stock_count)
			fighter.position = spawns[i]
			add_child(fighter)
			fighters.append(fighter)
			fighter.fighter_died.connect(_on_fighter_died)
			print("[Arena] P%d spawned at %s on frame %d" % [i + 1, fighter.position, Engine.get_physics_frames()])


# --- Camera ---

func _setup_camera() -> void:
	var cam_script = load("res://scripts/dynamic_camera.gd")
	dynamic_camera = Camera2D.new()
	dynamic_camera.set_script(cam_script)
	dynamic_camera.set("targets", fighters)
	dynamic_camera.global_position = Vector2(0, -60)
	dynamic_camera.zoom = Vector2(1.0, 1.0)
	add_child(dynamic_camera)


# --- Combat HUD ---

func _setup_combat_hud() -> void:
	var hud_script := load("res://scripts/combat_hud.gd")
	var canvas := CanvasLayer.new()
	canvas.name = "CombatHUDLayer"

	var hud := Control.new()
	hud.set_script(hud_script)
	hud.name = "CombatHUD"
	hud.set("fighters", fighters)
	hud.set("hide_p2", GameManager.training_mode)

	canvas.add_child(hud)
	add_child(canvas)
	combat_hud = hud


# --- Minimap ---

func _setup_minimap() -> void:
	var minimap_script := load("res://scripts/minimap.gd")
	var canvas := CanvasLayer.new()
	canvas.name = "MinimapLayer"

	var minimap = Control.new()
	minimap.set_script(minimap_script)
	minimap.name = "Minimap"
	minimap.set("fighters", fighters)
	minimap.set("platform_data", platform_data)

	canvas.add_child(minimap)
	add_child(canvas)


# --- Training Mode Overlay ---

func _setup_training_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "TrainingOverlay"
	canvas.layer = 5

	var label := Label.new()
	label.text = "TRAINING MODE"
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.offset_top = 20
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4, 0.7))
	canvas.add_child(label)

	var hint := Label.new()
	hint.text = "E + R to return to menu"
	hint.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint.offset_top = 54
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.7))
	canvas.add_child(hint)

	add_child(canvas)


# --- Match Flow ---

func _on_fighter_died(player_id: int) -> void:
	if match_over:
		return

	# The winner is the other player
	var winner := 2 if player_id == 1 else 1
	GameManager.last_winner = winner
	match_over = true
	return_timer = 3.5

	# Show winner overlay
	_show_winner(winner)


func _time_up() -> void:
	if match_over or fighters.size() < 2:
		return

	match_over = true
	return_timer = 3.5

	var f1 = fighters[0]
	var f2 = fighters[1]
	var s1: int = f1.stocks
	var s2: int = f2.stocks

	if s1 > s2:
		GameManager.last_winner = 1
		_show_winner(1)
	elif s2 > s1:
		GameManager.last_winner = 2
		_show_winner(2)
	else:
		# Stocks tied — compare damage (lower wins)
		var d1: float = f1.damage_percent
		var d2: float = f2.damage_percent
		if d1 < d2:
			GameManager.last_winner = 1
			_show_winner(1)
		elif d2 < d1:
			GameManager.last_winner = 2
			_show_winner(2)
		else:
			# True draw
			GameManager.last_winner = 0
			_show_draw()


func _show_winner(winner: int) -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "WinnerOverlay"
	canvas.layer = 10

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	canvas.add_child(overlay)

	var label := Label.new()
	label.text = "PLAYER %d WINS!" % winner
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 64)
	var win_color := Color(0.4, 0.7, 1.0) if winner == 1 else Color(1.0, 0.5, 0.4)
	label.add_theme_color_override("font_color", win_color)
	canvas.add_child(label)

	var sub := Label.new()
	sub.text = "Returning to main menu..."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	sub.offset_top = -80
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	canvas.add_child(sub)

	add_child(canvas)


func _show_draw() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "WinnerOverlay"
	canvas.layer = 10

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	canvas.add_child(overlay)

	var label := Label.new()
	label.text = "DRAW!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.31))
	canvas.add_child(label)

	var sub := Label.new()
	sub.text = "Returning to main menu..."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	sub.offset_top = -80
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	canvas.add_child(sub)

	add_child(canvas)
