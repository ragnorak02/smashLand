extends CharacterBody2D

## Base fighter controller — handles movement, multi-jump, gravity, and respawn.
## Configured per-player via player_id and per-character via fighter_type.

@export var player_id: int = 1
@export var fighter_type: int = 0  # 0 = Brawler, 1 = Speedster

# Movement tuning (overridden per fighter_type)
var move_speed: float = 450.0
var ground_accel: float = 2400.0
var ground_friction: float = 2400.0
var air_accel: float = 1400.0
var air_friction: float = 800.0

# Jump tuning
var jump_force: float = -520.0
var air_jump_force: float = -480.0
var max_jumps: int = 4
var gravity_force: float = 1200.0
var max_fall_speed: float = 900.0
var fast_fall_speed: float = 1200.0

# State
var jumps_remaining: int = 4
var facing_right: bool = true
var is_fast_falling: bool = false
var input_prefix: String = "p1_"
var spawn_position: Vector2 = Vector2.ZERO

# Boundaries
const KILL_ZONE_Y: float = 700.0
const KILL_ZONE_X: float = 1200.0

# Visual nodes (built in code)
var body_rect: ColorRect
var eye_left: ColorRect
var eye_right: ColorRect
var jump_label: Label


func _ready() -> void:
	input_prefix = "p%d_" % player_id
	spawn_position = position
	_apply_fighter_stats()
	_update_collision_shape()
	_build_visuals()


func _apply_fighter_stats() -> void:
	if fighter_type == 0:  # Brawler — heavier, stronger jumps, fewer air jumps
		move_speed = 380.0
		ground_accel = 2200.0
		jump_force = -560.0
		air_jump_force = -500.0
		max_jumps = 3
	else:  # Speedster — faster, more air jumps
		move_speed = 500.0
		ground_accel = 2800.0
		jump_force = -490.0
		air_jump_force = -450.0
		max_jumps = 4
	jumps_remaining = max_jumps


func _update_collision_shape() -> void:
	var col := $CollisionShape2D as CollisionShape2D
	if not col:
		return
	var size := Vector2(44, 68) if fighter_type == 0 else Vector2(36, 60)
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	col.position = Vector2(0, -size.y / 2.0)


func _build_visuals() -> void:
	var color: Color
	var body_w: float
	var body_h: float

	if fighter_type == 0:
		color = Color(0.2, 0.4, 0.9)
		body_w = 44.0
		body_h = 68.0
	else:
		color = Color(0.9, 0.2, 0.2)
		body_w = 36.0
		body_h = 60.0

	# Body rectangle (bottom-aligned at origin = feet)
	body_rect = ColorRect.new()
	body_rect.size = Vector2(body_w, body_h)
	body_rect.position = Vector2(-body_w / 2.0, -body_h)
	body_rect.color = color
	add_child(body_rect)

	# Lighter accent stripe at top
	var accent := ColorRect.new()
	accent.size = Vector2(body_w, 6)
	accent.position = Vector2(-body_w / 2.0, -body_h)
	accent.color = color.lightened(0.35)
	add_child(accent)

	# Eyes (show facing direction)
	eye_left = ColorRect.new()
	eye_left.size = Vector2(6, 8)
	eye_left.color = Color.WHITE
	add_child(eye_left)

	eye_right = ColorRect.new()
	eye_right.size = Vector2(6, 8)
	eye_right.color = Color.WHITE
	add_child(eye_right)

	_update_eyes()

	# Jump counter above head
	jump_label = Label.new()
	jump_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	jump_label.position = Vector2(-20, -body_h - 22)
	jump_label.size = Vector2(40, 20)
	jump_label.add_theme_font_size_override("font_size", 13)
	jump_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	add_child(jump_label)

	# Player tag
	var tag := Label.new()
	tag.text = "P%d" % player_id
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.position = Vector2(-20, -body_h - 38)
	tag.size = Vector2(40, 20)
	tag.add_theme_font_size_override("font_size", 12)
	var tag_color := Color(0.4, 0.7, 1.0) if player_id == 1 else Color(1.0, 0.5, 0.4)
	tag.add_theme_color_override("font_color", tag_color)
	add_child(tag)


func _update_eyes() -> void:
	if not body_rect:
		return
	var bw := body_rect.size.x
	var bh := body_rect.size.y
	var eye_y := -bh + 14.0

	if facing_right:
		eye_left.position = Vector2(bw / 2.0 - 18.0, eye_y)
		eye_right.position = Vector2(bw / 2.0 - 8.0, eye_y)
	else:
		eye_left.position = Vector2(-bw / 2.0 + 2.0, eye_y)
		eye_right.position = Vector2(-bw / 2.0 + 12.0, eye_y)


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# Reset on landing
	if on_floor:
		jumps_remaining = max_jumps
		is_fast_falling = false

	# Gravity
	if not on_floor:
		if is_fast_falling:
			velocity.y = move_toward(velocity.y, fast_fall_speed, gravity_force * delta)
		else:
			velocity.y += gravity_force * delta
			velocity.y = min(velocity.y, max_fall_speed)

	# Horizontal movement
	var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")

	if on_floor:
		if absf(dir) > 0.1:
			velocity.x = move_toward(velocity.x, dir * move_speed, ground_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
	else:
		if absf(dir) > 0.1:
			velocity.x = move_toward(velocity.x, dir * move_speed, air_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, air_friction * delta)

	# Update facing
	if dir > 0.1 and not facing_right:
		facing_right = true
		_update_eyes()
	elif dir < -0.1 and facing_right:
		facing_right = false
		_update_eyes()

	# Jump
	if Input.is_action_just_pressed(input_prefix + "jump"):
		if jumps_remaining > 0:
			if on_floor or jumps_remaining == max_jumps:
				velocity.y = jump_force
			else:
				velocity.y = air_jump_force
			jumps_remaining -= 1
			is_fast_falling = false

	# Fast fall
	if not on_floor and Input.is_action_just_pressed(input_prefix + "move_down"):
		if velocity.y >= 0:
			is_fast_falling = true
			velocity.y = fast_fall_speed * 0.75

	move_and_slide()

	# Jump counter display
	if jump_label:
		if not on_floor and jumps_remaining < max_jumps:
			jump_label.text = "x%d" % jumps_remaining
		else:
			jump_label.text = ""

	# Kill zone — respawn if too far off stage
	if position.y > KILL_ZONE_Y or absf(position.x) > KILL_ZONE_X:
		_respawn()


func _respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	jumps_remaining = max_jumps
	is_fast_falling = false


## Returns current horizontal input for HUD.
func get_input_direction() -> float:
	return Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")


## Returns whether jump is currently held for HUD.
func is_jump_held() -> bool:
	return Input.is_action_pressed(input_prefix + "jump")
