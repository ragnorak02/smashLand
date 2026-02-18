extends Control

## Arena minimap — shows platforms and fighter positions in a top-left overlay.
## Uses _draw() for efficient rendering, updated every frame.

var fighters: Array = []
var platform_data: Array[Dictionary] = []

# Minimap dimensions and position
const MAP_X: float = 10.0
const MAP_Y: float = 10.0
const MAP_W: float = 220.0
const MAP_H: float = 150.0
const MAP_MARGIN: float = 10.0

# World bounds to map from (covers kill zones + padding)
const WORLD_MIN_X: float = -1300.0
const WORLD_MAX_X: float = 1300.0
const WORLD_MIN_Y: float = -500.0
const WORLD_MAX_Y: float = 800.0

# Fighter colors (match body_color in fighter_base.gd)
const FIGHTER_COLORS: Array[Color] = [
	Color(0.2, 0.4, 0.9),  # Brawler (blue)
	Color(0.9, 0.2, 0.2),  # Speedster (red)
]


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	# Set size to cover the minimap area
	position = Vector2.ZERO
	size = Vector2(MAP_X + MAP_W + MAP_MARGIN, MAP_Y + MAP_H + MAP_MARGIN)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var map_rect := Rect2(MAP_X, MAP_Y, MAP_W, MAP_H)

	# Background
	draw_rect(map_rect, Color(0.05, 0.06, 0.1, 0.75))

	# Border
	var border_points: PackedVector2Array = [
		Vector2(MAP_X, MAP_Y),
		Vector2(MAP_X + MAP_W, MAP_Y),
		Vector2(MAP_X + MAP_W, MAP_Y + MAP_H),
		Vector2(MAP_X, MAP_Y + MAP_H),
		Vector2(MAP_X, MAP_Y),
	]
	draw_polyline(border_points, Color(0.35, 0.45, 0.6, 0.8), 1.5)

	# Kill zone boundary (faint red rectangle)
	var kz_tl := _world_to_map(Vector2(-1200.0, -450.0))
	var kz_br := _world_to_map(Vector2(1200.0, 700.0))
	var kz_rect := Rect2(kz_tl, kz_br - kz_tl)
	draw_rect(kz_rect, Color(1.0, 0.2, 0.2, 0.15))
	# Kill zone border
	var kz_points: PackedVector2Array = [
		kz_tl,
		Vector2(kz_br.x, kz_tl.y),
		kz_br,
		Vector2(kz_tl.x, kz_br.y),
		kz_tl,
	]
	draw_polyline(kz_points, Color(1.0, 0.3, 0.3, 0.3), 1.0)

	# Platforms
	for plat in platform_data:
		var plat_pos: Vector2 = plat["pos"]
		var plat_size: Vector2 = plat["size"]
		# Platform origin is center, so compute top-left corner in world space
		var world_tl := Vector2(plat_pos.x - plat_size.x / 2.0, plat_pos.y - plat_size.y / 2.0)
		var world_br := Vector2(plat_pos.x + plat_size.x / 2.0, plat_pos.y + plat_size.y / 2.0)
		var map_tl := _world_to_map(world_tl)
		var map_br := _world_to_map(world_br)
		var rect := Rect2(map_tl, map_br - map_tl)
		# Ensure minimum visible size
		rect.size.x = maxf(rect.size.x, 3.0)
		rect.size.y = maxf(rect.size.y, 2.0)
		draw_rect(rect, Color(0.3, 0.7, 0.3, 0.8))

	# Fighters
	var font := ThemeDB.fallback_font
	for i in range(fighters.size()):
		var fighter = fighters[i]
		if not is_instance_valid(fighter) or not fighter.visible:
			continue
		var map_pos := _world_to_map(fighter.global_position)
		# Clamp dot to minimap bounds (still show if just outside)
		map_pos.x = clampf(map_pos.x, MAP_X + 2.0, MAP_X + MAP_W - 2.0)
		map_pos.y = clampf(map_pos.y, MAP_Y + 2.0, MAP_Y + MAP_H - 2.0)

		var fighter_type: int = fighter.fighter_type if fighter.has_method("get_state_name") else 0
		var dot_color: Color = FIGHTER_COLORS[fighter_type] if fighter_type < FIGHTER_COLORS.size() else Color.WHITE
		draw_circle(map_pos, 4.0, dot_color)
		# Bright outline
		draw_arc(map_pos, 4.0, 0, TAU, 16, dot_color.lightened(0.4), 1.0)

		# Player label
		var label_text := "P%d" % fighter.player_id
		var label_pos := Vector2(map_pos.x - 7.0, map_pos.y - 8.0)
		draw_string(font, label_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1, 0.85))

	# Title
	draw_string(font, Vector2(MAP_X + 4.0, MAP_Y + MAP_H - 4.0), "MINIMAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.6, 0.65, 0.7, 0.5))


func _world_to_map(world_pos: Vector2) -> Vector2:
	var nx := (world_pos.x - WORLD_MIN_X) / (WORLD_MAX_X - WORLD_MIN_X)
	var ny := (world_pos.y - WORLD_MIN_Y) / (WORLD_MAX_Y - WORLD_MIN_Y)
	return Vector2(
		MAP_X + MAP_MARGIN + nx * (MAP_W - 2.0 * MAP_MARGIN),
		MAP_Y + MAP_MARGIN + ny * (MAP_H - 2.0 * MAP_MARGIN)
	)
