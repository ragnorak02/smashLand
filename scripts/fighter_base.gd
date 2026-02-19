extends CharacterBody2D

## Base fighter controller — state machine with full combat: attacks, knockback,
## hitstun/hitlag, shield, grab, stocks, and visual effects.

signal damage_changed(player_id: int, new_percent: float)
signal stock_changed(player_id: int, new_stocks: int)
signal fighter_died(player_id: int)

@export var player_id: int = 1
@export var fighter_type: int = 0  # 0 = Brawler, 1 = Speedster

# --- State Machine ---
enum State {
	IDLE, RUN, AIR, ATTACK, HITSTUN, SHIELD, SHIELD_STUN, SHIELD_BREAK,
	GRAB, GRAB_HOLD, GRABBED
}
var state: State = State.IDLE

# --- Movement tuning (set per fighter_type) ---
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

# --- Combat vars ---
var damage_percent: float = 0.0
var stocks: int = 3
var weight: float = 100.0
var attacks: Dictionary = {}

# Attack state
var current_attack: String = ""
var attack_timer: float = 0.0
var attack_phase: int = 0  # 0=startup, 1=active, 2=recovery
var active_hitbox: Area2D = null

# Hitlag
var hitlag_frames: int = 0
var hitlag_shake: bool = false

# Hitstun
var hitstun_timer: float = 0.0

# Shield
var shield_health: float = 100.0
const SHIELD_MAX: float = 100.0
const SHIELD_DRAIN_RATE: float = 15.0
const SHIELD_REGEN_RATE: float = 8.0
const SHIELD_REGEN_DELAY: float = 1.0
const SHIELD_BREAK_DURATION: float = 3.0
var shield_regen_cooldown: float = 0.0
var shield_stun_timer: float = 0.0
var shield_break_timer: float = 0.0

# Grab
var grab_target: CharacterBody2D = null
var grabbed_by: CharacterBody2D = null
var grab_hold_timer: float = 0.0
var grab_max_hold: float = 1.5
var grab_mash_count: int = 0
var grab_mash_threshold: int = 8
var pummel_cooldown: float = 0.0

# Invulnerability
var invulnerable: bool = false
var invuln_timer: float = 0.0
const INVULN_DURATION: float = 2.0

# Visual effects
var hit_flash_timer: float = 0.0
var knockback_trail_timer: float = 0.0

# Spawn safety
var _spawn_grace_frames: int = 5
var _debug_frame_count: int = 0

# Boundaries
const KILL_ZONE_Y: float = 700.0
const KILL_ZONE_X: float = 1200.0

# Visual nodes (built in code)
var body_rect: ColorRect
var eye_left: ColorRect
var eye_right: ColorRect
var jump_label: Label
var body_color: Color
var body_w: float
var body_h: float

# Hurtbox reference
var hurtbox: Area2D


func _ready() -> void:
	input_prefix = "p%d_" % player_id
	spawn_position = position
	_apply_fighter_stats()
	_update_collision_shape()
	_build_visuals()
	_setup_hurtbox()

	# Disable fighter-to-fighter push (keep world collision on layer 1)
	collision_layer = 1
	collision_mask = 1
	print("[Fighter P%d] _ready() pos=%s type=%d on frame %d" % [player_id, position, fighter_type, Engine.get_physics_frames()])


func _apply_fighter_stats() -> void:
	attacks = AttackData.get_attacks(fighter_type)
	weight = AttackData.get_weight(fighter_type)

	if fighter_type == 0:  # Brawler
		move_speed = 380.0
		ground_accel = 2200.0
		jump_force = -560.0
		air_jump_force = -500.0
		max_jumps = 3
	else:  # Speedster
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


func _setup_hurtbox() -> void:
	hurtbox = Area2D.new()
	hurtbox.name = "Hurtbox"

	# P1 hurtbox on layer 2, P2 on layer 3
	var hurtbox_layer := 2 if player_id == 1 else 3
	hurtbox.collision_layer = 1 << (hurtbox_layer - 1)
	hurtbox.collision_mask = 0  # Hurtboxes don't detect anything
	hurtbox.monitorable = true
	hurtbox.monitoring = false

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(body_w, body_h)
	col.shape = shape
	col.position = Vector2(0, -body_h / 2.0)
	hurtbox.add_child(col)
	add_child(hurtbox)


# --- Visual Construction ---

func _build_visuals() -> void:
	if fighter_type == 0:
		body_color = Color(0.2, 0.4, 0.9)
		body_w = 44.0
		body_h = 68.0
	else:
		body_color = Color(0.9, 0.2, 0.2)
		body_w = 36.0
		body_h = 60.0

	body_rect = ColorRect.new()
	body_rect.size = Vector2(body_w, body_h)
	body_rect.position = Vector2(-body_w / 2.0, -body_h)
	body_rect.color = body_color
	add_child(body_rect)

	var accent := ColorRect.new()
	accent.size = Vector2(body_w, 6)
	accent.position = Vector2(-body_w / 2.0, -body_h)
	accent.color = body_color.lightened(0.35)
	add_child(accent)

	eye_left = ColorRect.new()
	eye_left.size = Vector2(6, 8)
	eye_left.color = Color.WHITE
	add_child(eye_left)

	eye_right = ColorRect.new()
	eye_right.size = Vector2(6, 8)
	eye_right.color = Color.WHITE
	add_child(eye_right)

	_update_eyes()

	jump_label = Label.new()
	jump_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	jump_label.position = Vector2(-20, -body_h - 22)
	jump_label.size = Vector2(40, 20)
	jump_label.add_theme_font_size_override("font_size", 13)
	jump_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	add_child(jump_label)

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


# --- Main Physics Loop ---

func _physics_process(delta: float) -> void:
	# Pause freeze — keep visuals but stop all logic
	if GameManager.is_paused:
		queue_redraw()
		return

	# Hitlag freeze — skip everything except visual shake
	if hitlag_frames > 0:
		hitlag_frames -= 1
		hitlag_shake = true
		queue_redraw()
		return
	hitlag_shake = false

	# Invulnerability timer
	if invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0.0:
			invulnerable = false
			modulate.a = 1.0

	# Hit flash timer
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		if hit_flash_timer <= 0.0 and body_rect:
			body_rect.color = body_color

	# Knockback trail
	if knockback_trail_timer > 0.0:
		knockback_trail_timer -= delta

	# Shield regen (when not shielding)
	if state != State.SHIELD and state != State.SHIELD_STUN and state != State.SHIELD_BREAK:
		if shield_regen_cooldown > 0.0:
			shield_regen_cooldown -= delta
		elif shield_health < SHIELD_MAX:
			shield_health = minf(shield_health + SHIELD_REGEN_RATE * delta, SHIELD_MAX)

	var on_floor := is_on_floor()

	# Reset on landing (only for movement states)
	if on_floor and state in [State.IDLE, State.RUN, State.AIR]:
		jumps_remaining = max_jumps
		is_fast_falling = false
		if state == State.AIR:
			state = State.IDLE

	# Gravity (applies to most states)
	if not on_floor and state not in [State.GRABBED, State.GRAB_HOLD]:
		if is_fast_falling:
			velocity.y = move_toward(velocity.y, fast_fall_speed, gravity_force * delta)
		else:
			velocity.y += gravity_force * delta
			velocity.y = min(velocity.y, max_fall_speed)

	# State dispatch
	match state:
		State.IDLE:
			_state_idle(delta, on_floor)
		State.RUN:
			_state_run(delta, on_floor)
		State.AIR:
			_state_air(delta, on_floor)
		State.ATTACK:
			_state_attack(delta, on_floor)
		State.HITSTUN:
			_state_hitstun(delta, on_floor)
		State.SHIELD:
			_state_shield(delta, on_floor)
		State.SHIELD_STUN:
			_state_shield_stun(delta)
		State.SHIELD_BREAK:
			_state_shield_break(delta)
		State.GRAB:
			_state_grab(delta)
		State.GRAB_HOLD:
			_state_grab_hold(delta)
		State.GRABBED:
			_state_grabbed(delta)

	move_and_slide()

	# Spawn grace period — decrement after move_and_slide
	if _spawn_grace_frames > 0:
		_spawn_grace_frames -= 1

	# Diagnostic logging for first 10 frames
	_debug_frame_count += 1
	if _debug_frame_count <= 10:
		print("[Fighter P%d] frame=%d pos=%s vel=%s on_floor=%s grace=%d" % [
			player_id, _debug_frame_count, position, velocity, on_floor, _spawn_grace_frames])

	# Jump counter display
	if jump_label:
		if not on_floor and jumps_remaining < max_jumps:
			jump_label.text = "x%d" % jumps_remaining
		else:
			jump_label.text = ""

	# Kill zone (skip during spawn grace period)
	if _spawn_grace_frames <= 0 and (position.y > KILL_ZONE_Y or absf(position.x) > KILL_ZONE_X):
		_die()

	# Invulnerability blink
	if invulnerable:
		modulate.a = 0.3 + 0.7 * absf(sin(invuln_timer * 8.0))

	queue_redraw()


# --- State Handlers ---

func _state_idle(delta: float, on_floor: bool) -> void:
	_apply_horizontal_movement(delta, on_floor)
	_check_jump(on_floor)
	_check_combat_inputs(on_floor)

	var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")
	if absf(dir) > 0.1 and on_floor:
		state = State.RUN
	if not on_floor:
		state = State.AIR


func _state_run(delta: float, on_floor: bool) -> void:
	_apply_horizontal_movement(delta, on_floor)
	_check_jump(on_floor)
	_check_combat_inputs(on_floor)

	var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")
	if absf(dir) < 0.1 and on_floor:
		state = State.IDLE
	if not on_floor:
		state = State.AIR


func _state_air(delta: float, on_floor: bool) -> void:
	_apply_horizontal_movement(delta, on_floor)
	_check_jump(on_floor)
	_check_fast_fall(on_floor)
	_check_combat_inputs(on_floor)

	if on_floor:
		state = State.IDLE


func _state_attack(delta: float, on_floor: bool) -> void:
	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_phase += 1
		var atk := attacks.get(current_attack, {}) as Dictionary
		match attack_phase:
			1:  # Active frames — spawn hitbox
				attack_timer = atk.get("active", 0.06)
				_spawn_hitbox(atk)
			2:  # Recovery — remove hitbox
				attack_timer = atk.get("recovery", 0.15)
				_despawn_hitbox()
			3:  # Done
				_despawn_hitbox()
				current_attack = ""
				state = State.AIR if not on_floor else State.IDLE

	# Minimal air drift during attacks
	if not on_floor:
		var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")
		velocity.x = move_toward(velocity.x, dir * move_speed * 0.3, air_accel * 0.3 * delta)


func _state_hitstun(delta: float, on_floor: bool) -> void:
	hitstun_timer -= delta
	# Air friction during hitstun
	velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)

	if hitstun_timer <= 0.0:
		state = State.AIR if not on_floor else State.IDLE


func _state_shield(delta: float, on_floor: bool) -> void:
	# Drain shield health
	shield_health -= SHIELD_DRAIN_RATE * delta
	shield_regen_cooldown = SHIELD_REGEN_DELAY

	# Friction while shielding
	velocity.x = move_toward(velocity.x, 0.0, ground_friction * 1.5 * delta)

	if shield_health <= 0.0:
		# Shield break
		shield_health = 0.0
		shield_break_timer = SHIELD_BREAK_DURATION
		state = State.SHIELD_BREAK
		return

	# Can jump out of shield
	if Input.is_action_just_pressed(input_prefix + "jump"):
		state = State.IDLE
		_check_jump(on_floor)
		return

	# Can grab out of shield
	if Input.is_action_just_pressed(input_prefix + "grab"):
		_start_grab()
		return

	# Release shield
	if not Input.is_action_pressed(input_prefix + "shield"):
		state = State.IDLE if on_floor else State.AIR

	if not on_floor:
		state = State.AIR


func _state_shield_stun(delta: float) -> void:
	shield_stun_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
	if shield_stun_timer <= 0.0:
		state = State.SHIELD if Input.is_action_pressed(input_prefix + "shield") else State.IDLE


func _state_shield_break(delta: float) -> void:
	shield_break_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
	if shield_break_timer <= 0.0:
		shield_health = SHIELD_MAX * 0.3  # Partial recovery
		state = State.IDLE


func _state_grab(delta: float) -> void:
	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_phase += 1
		var atk := attacks.get("grab", {}) as Dictionary
		match attack_phase:
			1:  # Active — spawn grab hitbox
				attack_timer = atk.get("active", 0.06)
				_spawn_grab_hitbox(atk)
			2:  # Recovery — whiffed
				attack_timer = atk.get("recovery", 0.30)
				_despawn_hitbox()
			3:  # Done
				_despawn_hitbox()
				state = State.IDLE

	velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)


func _state_grab_hold(delta: float) -> void:
	grab_hold_timer -= delta
	pummel_cooldown -= delta
	velocity.x = 0.0

	if grab_target and is_instance_valid(grab_target):
		# Position victim in front
		var offset := 40.0 if facing_right else -40.0
		grab_target.position = Vector2(position.x + offset, position.y)
		grab_target.velocity = Vector2.ZERO

	# Pummel (attack while holding)
	if Input.is_action_just_pressed(input_prefix + "attack") and pummel_cooldown <= 0.0:
		_do_pummel()
		return

	# Directional throw
	var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")
	var vert := Input.get_axis(input_prefix + "move_up", input_prefix + "move_down")

	if absf(dir) > 0.5 or absf(vert) > 0.5:
		var throw_name := ""
		if absf(dir) >= absf(vert):
			if (dir > 0.0) == facing_right:
				throw_name = "throw_forward"
			else:
				throw_name = "throw_back"
		else:
			throw_name = "throw_up" if vert < 0.0 else "throw_down"
		_do_throw(throw_name)
		return

	# Hold time expired — victim escapes
	if grab_hold_timer <= 0.0:
		_release_grab()


func _state_grabbed(_delta: float) -> void:
	# Victim is locked in place by grabber
	velocity = Vector2.ZERO

	# Mash buttons to escape faster
	if Input.is_action_just_pressed(input_prefix + "attack") or \
	   Input.is_action_just_pressed(input_prefix + "jump") or \
	   Input.is_action_just_pressed(input_prefix + "shield") or \
	   Input.is_action_just_pressed(input_prefix + "grab"):
		if grabbed_by and is_instance_valid(grabbed_by):
			grabbed_by.grab_mash_count += 1
			if grabbed_by.grab_mash_count >= grabbed_by.grab_mash_threshold:
				grabbed_by._release_grab()


# --- Movement Helpers ---

func _apply_horizontal_movement(delta: float, on_floor: bool) -> void:
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


func _check_jump(on_floor: bool) -> void:
	if Input.is_action_just_pressed(input_prefix + "jump"):
		if jumps_remaining > 0:
			if on_floor or jumps_remaining == max_jumps:
				velocity.y = jump_force
			else:
				velocity.y = air_jump_force
			jumps_remaining -= 1
			is_fast_falling = false
			if not on_floor or state == State.AIR:
				state = State.AIR


func _check_fast_fall(on_floor: bool) -> void:
	if not on_floor and Input.is_action_just_pressed(input_prefix + "move_down"):
		if velocity.y >= 0:
			is_fast_falling = true
			velocity.y = fast_fall_speed * 0.75


func _check_combat_inputs(on_floor: bool) -> void:
	# Shield (ground only)
	if on_floor and Input.is_action_pressed(input_prefix + "shield"):
		if shield_health > 0.0:
			state = State.SHIELD
			return

	# Attack
	if Input.is_action_just_pressed(input_prefix + "attack"):
		var attack_name := _determine_attack(on_floor)
		_start_attack(attack_name)
		return

	# Grab (ground only)
	if on_floor and Input.is_action_just_pressed(input_prefix + "grab"):
		_start_grab()
		return


# --- Attack System ---

func _determine_attack(on_floor: bool) -> String:
	var dir := Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")
	var vert := Input.get_axis(input_prefix + "move_up", input_prefix + "move_down")

	if on_floor:
		if absf(dir) > 0.3:
			return "ground_forward"
		return "ground_neutral"
	else:
		# Air attacks — check direction
		if vert < -0.3:
			return "air_up"
		if vert > 0.3:
			return "air_down"
		if absf(dir) > 0.3:
			if (dir > 0.0) == facing_right:
				return "air_forward"
			else:
				return "air_back"
		return "air_neutral"


func _start_attack(attack_name: String) -> void:
	if not attacks.has(attack_name):
		return
	current_attack = attack_name
	attack_phase = 0  # startup
	attack_timer = attacks[attack_name].get("startup", 0.08)
	state = State.ATTACK


func _spawn_hitbox(atk: Dictionary) -> void:
	_despawn_hitbox()

	var hb := Area2D.new()
	var hb_script := load("res://scripts/combat/hitbox.gd")
	hb.set_script(hb_script)
	hb.set("attack_data", atk)
	hb.set("attacker", self)

	# P1 hitbox on layer 4 (masks P2 hurtbox layer 3)
	# P2 hitbox on layer 5 (masks P1 hurtbox layer 2)
	var hitbox_layer := 4 if player_id == 1 else 5
	var target_hurtbox := 3 if player_id == 1 else 2
	hb.collision_layer = 1 << (hitbox_layer - 1)
	hb.collision_mask = 1 << (target_hurtbox - 1)
	hb.monitoring = true
	hb.monitorable = false

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = atk.get("hitbox_size", Vector2(40, 40))
	col.shape = shape

	var offset: Vector2 = atk.get("hitbox_offset", Vector2(30, -34))
	if not facing_right:
		offset.x = -offset.x
	col.position = offset

	hb.add_child(col)
	add_child(hb)
	active_hitbox = hb


func _despawn_hitbox() -> void:
	if active_hitbox and is_instance_valid(active_hitbox):
		active_hitbox.queue_free()
		active_hitbox = null


# --- Grab System ---

func _start_grab() -> void:
	if not attacks.has("grab"):
		return
	current_attack = "grab"
	attack_phase = 0
	attack_timer = attacks["grab"].get("startup", 0.06)
	state = State.GRAB


func _spawn_grab_hitbox(atk: Dictionary) -> void:
	_despawn_hitbox()

	var hb := Area2D.new()
	hb.name = "GrabHitbox"

	var hitbox_layer := 4 if player_id == 1 else 5
	var target_hurtbox := 3 if player_id == 1 else 2
	hb.collision_layer = 1 << (hitbox_layer - 1)
	hb.collision_mask = 1 << (target_hurtbox - 1)
	hb.monitoring = true
	hb.monitorable = false

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = atk.get("hitbox_size", Vector2(36, 44))
	col.shape = shape

	var offset: Vector2 = atk.get("hitbox_offset", Vector2(34, -34))
	if not facing_right:
		offset.x = -offset.x
	col.position = offset

	hb.add_child(col)
	add_child(hb)
	active_hitbox = hb

	# Connect grab detection
	hb.area_entered.connect(_on_grab_connect)


func _on_grab_connect(area: Area2D) -> void:
	var victim = area.get_parent()
	if victim == self:
		return
	if not victim is CharacterBody2D:
		return
	if not victim.has_method("get_grabbed"):
		return

	# Grab beats shield — check if victim is shielding or in a grabbable state
	var victim_state = victim.get("state")
	if victim_state in [State.HITSTUN, State.GRABBED, State.GRAB_HOLD, State.SHIELD_BREAK]:
		return  # Can't grab these states

	_despawn_hitbox()
	grab_target = victim
	victim.get_grabbed(self)

	state = State.GRAB_HOLD
	attack_phase = 0
	# Hold duration scales with victim damage
	grab_hold_timer = 0.6 + (victim.damage_percent / 200.0)
	grab_hold_timer = clampf(grab_hold_timer, 0.4, 2.0)
	grab_mash_count = 0
	grab_mash_threshold = 8 + int(victim.damage_percent / 20.0)
	pummel_cooldown = 0.0


func get_grabbed(grabber: CharacterBody2D) -> void:
	grabbed_by = grabber
	state = State.GRABBED
	_despawn_hitbox()
	velocity = Vector2.ZERO


func _do_pummel() -> void:
	if not grab_target or not is_instance_valid(grab_target):
		_release_grab()
		return
	var atk := attacks.get("pummel", {}) as Dictionary
	var dmg: float = atk.get("damage", 2.0)
	grab_target.damage_percent += dmg
	grab_target.emit_signal("damage_changed", grab_target.player_id, grab_target.damage_percent)
	pummel_cooldown = atk.get("recovery", 0.20)

	# Visual flash on victim
	if grab_target.body_rect:
		grab_target.body_rect.color = Color.WHITE
		grab_target.hit_flash_timer = 0.08


func _do_throw(throw_name: String) -> void:
	if not grab_target or not is_instance_valid(grab_target):
		_release_grab()
		return

	var atk := attacks.get(throw_name, attacks.get("throw_forward", {})) as Dictionary

	# Apply throw damage
	var dmg: float = atk.get("damage", 8.0)
	grab_target.damage_percent += dmg
	grab_target.emit_signal("damage_changed", grab_target.player_id, grab_target.damage_percent)

	# Apply knockback
	var angle: float = atk.get("angle", 0.4)
	# Flip horizontal for back throw or if not facing right
	if throw_name == "throw_back":
		if facing_right:
			angle = PI - angle
	elif not facing_right:
		angle = PI - angle

	var base_kb: float = atk.get("base_kb", 50.0)
	var kb_scaling: float = atk.get("kb_scaling", 80.0)
	var kb_mag: float = (base_kb + (grab_target.damage_percent * kb_scaling / 10.0)) * (200.0 / (grab_target.weight + 100.0))

	grab_target.velocity = Vector2(cos(angle), -sin(angle)) * kb_mag

	# Hitstun on victim
	var hitstun := clampf(kb_mag * 0.5 / 60.0, 0.1, 3.0)
	grab_target.hitstun_timer = hitstun
	grab_target.state = State.HITSTUN
	grab_target.knockback_trail_timer = 0.3
	grab_target.grabbed_by = null

	# Hitlag
	var hl: int = atk.get("hitlag_frames", 4)
	hitlag_frames = hl
	grab_target.hitlag_frames = hl

	grab_target = null
	state = State.IDLE


func _release_grab() -> void:
	if grab_target and is_instance_valid(grab_target):
		grab_target.state = State.IDLE
		grab_target.grabbed_by = null
		# Push apart
		var push_dir := 1.0 if facing_right else -1.0
		grab_target.velocity = Vector2(push_dir * 200.0, -100.0)
	grab_target = null
	state = State.IDLE


# --- Damage / Knockback ---

func take_hit(atk: Dictionary, attacker: CharacterBody2D) -> void:
	if invulnerable:
		return

	# Shield check
	if state == State.SHIELD or state == State.SHIELD_STUN:
		_shield_hit(atk, attacker)
		return

	var dmg: float = atk.get("damage", 5.0)
	damage_percent += dmg
	emit_signal("damage_changed", player_id, damage_percent)

	# Knockback calculation
	var angle: float = atk.get("angle", 0.5)
	var base_kb: float = atk.get("base_kb", 30.0)
	var kb_scaling: float = atk.get("kb_scaling", 80.0)
	var kb_mag: float = (base_kb + (damage_percent * kb_scaling / 10.0)) * (200.0 / (weight + 100.0))

	# Flip angle based on attacker position
	if attacker.global_position.x > global_position.x:
		angle = PI - angle

	velocity = Vector2(cos(angle), -sin(angle)) * kb_mag

	# Hitstun
	hitstun_timer = clampf(kb_mag * 0.5 / 60.0, 0.1, 3.0)
	state = State.HITSTUN

	# Hitlag on both fighters
	var hl: int = atk.get("hitlag_frames", 4)
	hitlag_frames = hl
	attacker.hitlag_frames = hl

	# Visual effects
	if body_rect:
		body_rect.color = Color.WHITE
		hit_flash_timer = 0.1
	knockback_trail_timer = 0.3


func _shield_hit(atk: Dictionary, attacker: CharacterBody2D) -> void:
	var dmg: float = atk.get("damage", 5.0)
	shield_health -= dmg * 1.5

	# Pushback
	var push_dir := -1.0 if attacker.global_position.x > global_position.x else 1.0
	velocity.x = push_dir * 150.0

	# Shield stun
	shield_stun_timer = 0.2
	state = State.SHIELD_STUN
	shield_regen_cooldown = SHIELD_REGEN_DELAY

	# Hitlag on attacker
	var hl: int = atk.get("hitlag_frames", 4)
	attacker.hitlag_frames = hl

	if shield_health <= 0.0:
		shield_health = 0.0
		shield_break_timer = SHIELD_BREAK_DURATION
		state = State.SHIELD_BREAK


# --- Death / Respawn ---

func _die() -> void:
	print("[Fighter P%d] _die() at pos=%s frame=%d" % [player_id, position, _debug_frame_count])
	if GameManager.training_mode:
		_respawn()
		return

	stocks -= 1
	emit_signal("stock_changed", player_id, stocks)

	if stocks <= 0:
		emit_signal("fighter_died", player_id)
		# Stay visible at spawn but inactive
		position = spawn_position
		velocity = Vector2.ZERO
		state = State.IDLE
		set_physics_process(false)
		visible = false
		return

	_respawn()


func _respawn() -> void:
	print("[Fighter P%d] _respawn() to %s on frame %d" % [player_id, spawn_position, _debug_frame_count])
	position = spawn_position
	velocity = Vector2.ZERO
	damage_percent = 0.0
	emit_signal("damage_changed", player_id, damage_percent)
	jumps_remaining = max_jumps
	is_fast_falling = false
	state = State.IDLE
	_despawn_hitbox()
	_spawn_grace_frames = 5

	# Invulnerability
	invulnerable = true
	invuln_timer = INVULN_DURATION

	# Release grab if any
	if grabbed_by and is_instance_valid(grabbed_by):
		grabbed_by.grab_target = null
		grabbed_by.state = State.IDLE
		grabbed_by = null
	if grab_target and is_instance_valid(grab_target):
		grab_target.state = State.IDLE
		grab_target.grabbed_by = null
		grab_target = null


# --- Draw (shield, hitbox overlay, shield break stars, knockback trail) ---

func _draw() -> void:
	# Hitlag shake offset
	if hitlag_shake:
		var shake := Vector2(randf_range(-3, 3), randf_range(-3, 3))
		draw_set_transform(shake)
	else:
		draw_set_transform(Vector2.ZERO)

	# Shield visual
	if state == State.SHIELD or state == State.SHIELD_STUN:
		var ratio := shield_health / SHIELD_MAX
		var radius := 38.0 * ratio + 10.0
		var shield_color := Color(0.3, 0.6, 1.0, 0.35).lerp(Color(1.0, 0.2, 0.2, 0.35), 1.0 - ratio)
		draw_circle(Vector2(0, -body_h / 2.0), radius, shield_color)
		# Shield border
		var border_color := Color(0.5, 0.8, 1.0, 0.6).lerp(Color(1.0, 0.3, 0.3, 0.6), 1.0 - ratio)
		draw_arc(Vector2(0, -body_h / 2.0), radius, 0, TAU, 32, border_color, 2.0)

	# Shield break stars
	if state == State.SHIELD_BREAK:
		var t := shield_break_timer
		for i in range(3):
			var star_angle := t * 4.0 + i * TAU / 3.0
			var star_pos := Vector2(cos(star_angle) * 20.0, -body_h - 10.0 + sin(star_angle) * 8.0)
			draw_circle(star_pos, 4.0, Color(1.0, 0.9, 0.1, 0.9))

	# Active hitbox overlay
	if active_hitbox and is_instance_valid(active_hitbox) and active_hitbox.get_child_count() > 0:
		var col_shape := active_hitbox.get_child(0) as CollisionShape2D
		if col_shape and col_shape.shape is RectangleShape2D:
			var rect_shape := col_shape.shape as RectangleShape2D
			var rect_pos := col_shape.position - rect_shape.size / 2.0
			var hb_color := Color(1.0, 0.9, 0.0, 0.3)
			if state == State.GRAB:
				hb_color = Color(0.0, 1.0, 0.5, 0.3)
			draw_rect(Rect2(rect_pos, rect_shape.size), hb_color)

	# Knockback trail
	if knockback_trail_timer > 0.0:
		var alpha := knockback_trail_timer / 0.3
		var trail_color := Color(1.0, 0.6, 0.2, alpha * 0.5)
		var trail_dir := -velocity.normalized() * 20.0
		draw_line(Vector2(0, -body_h / 2.0), Vector2(0, -body_h / 2.0) + trail_dir, trail_color, 3.0)

	# Reset transform
	draw_set_transform(Vector2.ZERO)


# --- Public Accessors (for HUD/debug) ---

func get_input_direction() -> float:
	return Input.get_axis(input_prefix + "move_left", input_prefix + "move_right")


func is_jump_held() -> bool:
	return Input.is_action_pressed(input_prefix + "jump")


func get_state_name() -> String:
	return State.keys()[state]


func mash_escape() -> void:
	# Called by grabbed victim when they press buttons
	grab_mash_count += 1
