class_name AttackData
extends RefCounted

## Static attack dictionaries for each fighter type.
## Keys: damage, angle (radians), base_kb, kb_scaling, hitlag_frames,
##        startup, active, recovery (in seconds), hitbox_offset, hitbox_size.

# --- Brawler (type 0) ---
# Higher damage, slower startup, bigger hitboxes, weight 100

const BRAWLER_WEIGHT := 100.0

const BRAWLER := {
	"ground_neutral": {
		"damage": 10.0, "angle": 0.6, "base_kb": 40.0, "kb_scaling": 90.0,
		"hitlag_frames": 5, "startup": 0.08, "active": 0.08, "recovery": 0.18,
		"hitbox_offset": Vector2(30, -34), "hitbox_size": Vector2(44, 44),
	},
	"ground_forward": {
		"damage": 14.0, "angle": 0.35, "base_kb": 50.0, "kb_scaling": 100.0,
		"hitlag_frames": 7, "startup": 0.12, "active": 0.07, "recovery": 0.24,
		"hitbox_offset": Vector2(40, -34), "hitbox_size": Vector2(52, 40),
	},
	"ground_up": {
		"damage": 11.0, "angle": 1.3, "base_kb": 45.0, "kb_scaling": 95.0,
		"hitlag_frames": 6, "startup": 0.10, "active": 0.07, "recovery": 0.20,
		"hitbox_offset": Vector2(0, -68), "hitbox_size": Vector2(48, 44),
	},
	"ground_down": {
		"damage": 10.0, "angle": 0.2, "base_kb": 35.0, "kb_scaling": 85.0,
		"hitlag_frames": 5, "startup": 0.08, "active": 0.08, "recovery": 0.18,
		"hitbox_offset": Vector2(30, -10), "hitbox_size": Vector2(56, 28),
	},
	"smash_forward": {
		"damage": 20.0, "angle": 0.3, "base_kb": 60.0, "kb_scaling": 110.0,
		"hitlag_frames": 9, "startup": 0.18, "active": 0.08, "recovery": 0.32,
		"hitbox_offset": Vector2(44, -34), "hitbox_size": Vector2(60, 48),
	},
	"smash_up": {
		"damage": 18.0, "angle": 1.4, "base_kb": 55.0, "kb_scaling": 105.0,
		"hitlag_frames": 8, "startup": 0.16, "active": 0.07, "recovery": 0.30,
		"hitbox_offset": Vector2(0, -72), "hitbox_size": Vector2(52, 52),
	},
	"smash_down": {
		"damage": 16.0, "angle": 0.15, "base_kb": 50.0, "kb_scaling": 95.0,
		"hitlag_frames": 7, "startup": 0.14, "active": 0.08, "recovery": 0.28,
		"hitbox_offset": Vector2(0, -10), "hitbox_size": Vector2(64, 30),
	},
	"special_neutral": {
		"damage": 12.0, "angle": 0.5, "base_kb": 45.0, "kb_scaling": 90.0,
		"hitlag_frames": 6, "startup": 0.12, "active": 0.08, "recovery": 0.22,
		"hitbox_offset": Vector2(34, -34), "hitbox_size": Vector2(48, 44),
	},
	"special_forward": {
		"damage": 14.0, "angle": 0.3, "base_kb": 50.0, "kb_scaling": 95.0,
		"hitlag_frames": 7, "startup": 0.14, "active": 0.07, "recovery": 0.26,
		"hitbox_offset": Vector2(42, -34), "hitbox_size": Vector2(52, 40),
	},
	"special_up": {
		"damage": 11.0, "angle": 1.4, "base_kb": 50.0, "kb_scaling": 100.0,
		"hitlag_frames": 6, "startup": 0.10, "active": 0.08, "recovery": 0.24,
		"hitbox_offset": Vector2(0, -70), "hitbox_size": Vector2(44, 48),
	},
	"special_down": {
		"damage": 15.0, "angle": -1.2, "base_kb": 55.0, "kb_scaling": 90.0,
		"hitlag_frames": 8, "startup": 0.16, "active": 0.06, "recovery": 0.30,
		"hitbox_offset": Vector2(0, -8), "hitbox_size": Vector2(52, 36),
	},
	"air_neutral": {
		"damage": 9.0, "angle": 0.7, "base_kb": 35.0, "kb_scaling": 80.0,
		"hitlag_frames": 4, "startup": 0.06, "active": 0.10, "recovery": 0.14,
		"hitbox_offset": Vector2(0, -34), "hitbox_size": Vector2(56, 56),
	},
	"air_forward": {
		"damage": 13.0, "angle": 0.3, "base_kb": 45.0, "kb_scaling": 95.0,
		"hitlag_frames": 6, "startup": 0.10, "active": 0.06, "recovery": 0.22,
		"hitbox_offset": Vector2(38, -34), "hitbox_size": Vector2(48, 36),
	},
	"air_back": {
		"damage": 15.0, "angle": 2.8, "base_kb": 55.0, "kb_scaling": 105.0,
		"hitlag_frames": 8, "startup": 0.12, "active": 0.06, "recovery": 0.26,
		"hitbox_offset": Vector2(-38, -34), "hitbox_size": Vector2(48, 36),
	},
	"air_up": {
		"damage": 12.0, "angle": 1.4, "base_kb": 45.0, "kb_scaling": 100.0,
		"hitlag_frames": 6, "startup": 0.08, "active": 0.07, "recovery": 0.20,
		"hitbox_offset": Vector2(0, -68), "hitbox_size": Vector2(48, 40),
	},
	"air_down": {
		"damage": 16.0, "angle": -1.57, "base_kb": 50.0, "kb_scaling": 80.0,
		"hitlag_frames": 8, "startup": 0.14, "active": 0.06, "recovery": 0.30,
		"hitbox_offset": Vector2(0, 0), "hitbox_size": Vector2(40, 44),
	},
	"grab": {
		"startup": 0.06, "active": 0.06, "recovery": 0.30,
		"hitbox_offset": Vector2(34, -34), "hitbox_size": Vector2(36, 44),
	},
	"pummel": {
		"damage": 3.0, "startup": 0.04, "active": 0.02, "recovery": 0.20,
	},
	"throw_forward": {
		"damage": 10.0, "angle": 0.4, "base_kb": 60.0, "kb_scaling": 80.0,
		"hitlag_frames": 4,
	},
	"throw_back": {
		"damage": 11.0, "angle": 2.7, "base_kb": 65.0, "kb_scaling": 85.0,
		"hitlag_frames": 4,
	},
	"throw_up": {
		"damage": 9.0, "angle": 1.47, "base_kb": 55.0, "kb_scaling": 90.0,
		"hitlag_frames": 4,
	},
	"throw_down": {
		"damage": 8.0, "angle": -1.47, "base_kb": 50.0, "kb_scaling": 70.0,
		"hitlag_frames": 4,
	},
}

# --- Speedster (type 1) ---
# Lower damage, faster startup, smaller hitboxes, weight 80

const SPEEDSTER_WEIGHT := 80.0

const SPEEDSTER := {
	"ground_neutral": {
		"damage": 7.0, "angle": 0.6, "base_kb": 30.0, "kb_scaling": 80.0,
		"hitlag_frames": 3, "startup": 0.05, "active": 0.06, "recovery": 0.12,
		"hitbox_offset": Vector2(26, -30), "hitbox_size": Vector2(36, 36),
	},
	"ground_forward": {
		"damage": 10.0, "angle": 0.35, "base_kb": 40.0, "kb_scaling": 90.0,
		"hitlag_frames": 5, "startup": 0.08, "active": 0.06, "recovery": 0.16,
		"hitbox_offset": Vector2(34, -30), "hitbox_size": Vector2(42, 32),
	},
	"ground_up": {
		"damage": 8.0, "angle": 1.3, "base_kb": 35.0, "kb_scaling": 85.0,
		"hitlag_frames": 4, "startup": 0.07, "active": 0.06, "recovery": 0.14,
		"hitbox_offset": Vector2(0, -60), "hitbox_size": Vector2(40, 38),
	},
	"ground_down": {
		"damage": 7.0, "angle": 0.2, "base_kb": 28.0, "kb_scaling": 75.0,
		"hitlag_frames": 3, "startup": 0.06, "active": 0.06, "recovery": 0.12,
		"hitbox_offset": Vector2(26, -8), "hitbox_size": Vector2(48, 24),
	},
	"smash_forward": {
		"damage": 15.0, "angle": 0.3, "base_kb": 50.0, "kb_scaling": 100.0,
		"hitlag_frames": 7, "startup": 0.13, "active": 0.07, "recovery": 0.24,
		"hitbox_offset": Vector2(38, -30), "hitbox_size": Vector2(52, 40),
	},
	"smash_up": {
		"damage": 13.0, "angle": 1.4, "base_kb": 45.0, "kb_scaling": 95.0,
		"hitlag_frames": 6, "startup": 0.11, "active": 0.06, "recovery": 0.22,
		"hitbox_offset": Vector2(0, -64), "hitbox_size": Vector2(44, 44),
	},
	"smash_down": {
		"damage": 12.0, "angle": 0.15, "base_kb": 40.0, "kb_scaling": 85.0,
		"hitlag_frames": 5, "startup": 0.10, "active": 0.07, "recovery": 0.20,
		"hitbox_offset": Vector2(0, -8), "hitbox_size": Vector2(56, 26),
	},
	"special_neutral": {
		"damage": 8.0, "angle": 0.5, "base_kb": 35.0, "kb_scaling": 80.0,
		"hitlag_frames": 4, "startup": 0.08, "active": 0.07, "recovery": 0.16,
		"hitbox_offset": Vector2(28, -30), "hitbox_size": Vector2(40, 38),
	},
	"special_forward": {
		"damage": 10.0, "angle": 0.3, "base_kb": 40.0, "kb_scaling": 85.0,
		"hitlag_frames": 5, "startup": 0.10, "active": 0.06, "recovery": 0.18,
		"hitbox_offset": Vector2(36, -30), "hitbox_size": Vector2(44, 34),
	},
	"special_up": {
		"damage": 7.0, "angle": 1.4, "base_kb": 40.0, "kb_scaling": 90.0,
		"hitlag_frames": 4, "startup": 0.07, "active": 0.07, "recovery": 0.16,
		"hitbox_offset": Vector2(0, -62), "hitbox_size": Vector2(38, 42),
	},
	"special_down": {
		"damage": 11.0, "angle": -1.2, "base_kb": 45.0, "kb_scaling": 80.0,
		"hitlag_frames": 6, "startup": 0.12, "active": 0.05, "recovery": 0.22,
		"hitbox_offset": Vector2(0, -6), "hitbox_size": Vector2(44, 30),
	},
	"air_neutral": {
		"damage": 6.0, "angle": 0.7, "base_kb": 25.0, "kb_scaling": 70.0,
		"hitlag_frames": 3, "startup": 0.04, "active": 0.08, "recovery": 0.10,
		"hitbox_offset": Vector2(0, -30), "hitbox_size": Vector2(48, 48),
	},
	"air_forward": {
		"damage": 9.0, "angle": 0.3, "base_kb": 35.0, "kb_scaling": 85.0,
		"hitlag_frames": 4, "startup": 0.06, "active": 0.05, "recovery": 0.14,
		"hitbox_offset": Vector2(32, -30), "hitbox_size": Vector2(40, 30),
	},
	"air_back": {
		"damage": 11.0, "angle": 2.8, "base_kb": 45.0, "kb_scaling": 95.0,
		"hitlag_frames": 6, "startup": 0.08, "active": 0.05, "recovery": 0.18,
		"hitbox_offset": Vector2(-32, -30), "hitbox_size": Vector2(40, 30),
	},
	"air_up": {
		"damage": 8.0, "angle": 1.4, "base_kb": 35.0, "kb_scaling": 90.0,
		"hitlag_frames": 4, "startup": 0.05, "active": 0.06, "recovery": 0.14,
		"hitbox_offset": Vector2(0, -60), "hitbox_size": Vector2(40, 36),
	},
	"air_down": {
		"damage": 12.0, "angle": -1.57, "base_kb": 40.0, "kb_scaling": 70.0,
		"hitlag_frames": 6, "startup": 0.10, "active": 0.05, "recovery": 0.22,
		"hitbox_offset": Vector2(0, 0), "hitbox_size": Vector2(34, 38),
	},
	"grab": {
		"startup": 0.04, "active": 0.05, "recovery": 0.26,
		"hitbox_offset": Vector2(28, -30), "hitbox_size": Vector2(30, 38),
	},
	"pummel": {
		"damage": 2.0, "startup": 0.03, "active": 0.02, "recovery": 0.16,
	},
	"throw_forward": {
		"damage": 7.0, "angle": 0.4, "base_kb": 50.0, "kb_scaling": 75.0,
		"hitlag_frames": 3,
	},
	"throw_back": {
		"damage": 8.0, "angle": 2.7, "base_kb": 55.0, "kb_scaling": 80.0,
		"hitlag_frames": 3,
	},
	"throw_up": {
		"damage": 6.0, "angle": 1.47, "base_kb": 45.0, "kb_scaling": 85.0,
		"hitlag_frames": 3,
	},
	"throw_down": {
		"damage": 5.0, "angle": -1.47, "base_kb": 40.0, "kb_scaling": 65.0,
		"hitlag_frames": 3,
	},
}

static func get_attacks(fighter_type: int) -> Dictionary:
	return BRAWLER if fighter_type == 0 else SPEEDSTER

static func get_weight(fighter_type: int) -> float:
	return BRAWLER_WEIGHT if fighter_type == 0 else SPEEDSTER_WEIGHT
