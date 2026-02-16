extends Camera2D

## Shared dynamic camera that tracks all fighters.
## Smoothly zooms out when fighters separate, zooms in when close.
## Uses interpolation for stable, polished framing.

var targets: Array = []

const MIN_ZOOM: float = 0.4
const MAX_ZOOM: float = 1.4
const MARGIN_X: float = 280.0
const MARGIN_Y: float = 220.0
const POS_LERP_SPEED: float = 4.5
const ZOOM_LERP_SPEED: float = 2.5
const VERTICAL_BIAS: float = -40.0  # Camera looks slightly above center


func _process(delta: float) -> void:
	if targets.is_empty():
		return

	# Bounding box of all targets
	var min_pos: Vector2 = targets[0].global_position
	var max_pos: Vector2 = targets[0].global_position

	for target in targets:
		var pos: Vector2 = target.global_position
		min_pos.x = minf(min_pos.x, pos.x)
		min_pos.y = minf(min_pos.y, pos.y)
		max_pos.x = maxf(max_pos.x, pos.x)
		max_pos.y = maxf(max_pos.y, pos.y)

	# Smoothly move to center of targets
	var center := (min_pos + max_pos) * 0.5
	center.y += VERTICAL_BIAS
	global_position = global_position.lerp(center, POS_LERP_SPEED * delta)

	# Calculate zoom to fit all targets with margin
	var span := max_pos - min_pos
	var viewport_size := get_viewport_rect().size
	var zoom_for_x := viewport_size.x / (span.x + MARGIN_X * 2.0)
	var zoom_for_y := viewport_size.y / (span.y + MARGIN_Y * 2.0)
	var target_zoom := minf(zoom_for_x, zoom_for_y)
	target_zoom = clampf(target_zoom, MIN_ZOOM, MAX_ZOOM)

	# Smoothly interpolate zoom
	var new_zoom := lerpf(zoom.x, target_zoom, ZOOM_LERP_SPEED * delta)
	zoom = Vector2(new_zoom, new_zoom)
