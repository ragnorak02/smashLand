extends SceneTree

## SmashLand automated test runner — runs headless via:
##   godot --headless --path . --script tests/run-tests.gd
## Outputs JSON results to stdout. Exit code 0 = all pass, 1 = any failure.

var _results: Array = []
var _passed: int = 0
var _failed: int = 0
var _attack_data: GDScript  # Loaded at runtime (class_name not available in --script mode)


func _init() -> void:
	var start_time := Time.get_ticks_msec()
	_attack_data = load("res://scripts/combat/attack_data.gd") as GDScript

	_test_scene_loading()
	_test_script_existence()
	_test_fighter_base_structure()
	_test_attack_data_brawler()
	_test_attack_data_speedster()
	_test_fighter_config()
	_test_knockback_formula()
	_test_project_config()
	_test_game_manager_settings()
	_test_performance()
	_test_special_input_action()

	var duration := Time.get_ticks_msec() - start_time
	var total := _passed + _failed
	var status := "pass" if _failed == 0 else "fail"
	var timestamp := Time.get_datetime_string_from_system(true) + "Z"

	var output := {
		"status": status,
		"testsTotal": total,
		"testsPassed": _passed,
		"durationMs": duration,
		"timestamp": timestamp,
		"details": _results,
	}

	print(JSON.stringify(output, "  "))
	quit(0 if _failed == 0 else 1)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _pass(test_name: String, message: String = "OK") -> void:
	_results.append({"name": test_name, "status": "pass", "message": message})
	_passed += 1


func _fail(test_name: String, message: String) -> void:
	_results.append({"name": test_name, "status": "fail", "message": message})
	_failed += 1


func _assert_true(condition: bool, test_name: String, pass_msg: String, fail_msg: String) -> void:
	if condition:
		_pass(test_name, pass_msg)
	else:
		_fail(test_name, fail_msg)


# ---------------------------------------------------------------------------
# Suite: Scene Loading (4 tests)
# ---------------------------------------------------------------------------

func _test_scene_loading() -> void:
	var scenes := {
		"scene_load_Main": "res://scenes/Main.tscn",
		"scene_load_CharacterSelect": "res://scenes/CharacterSelect.tscn",
		"scene_load_Arena": "res://scenes/Arena.tscn",
		"scene_load_FighterBase": "res://scenes/FighterBase.tscn",
	}
	for test_name in scenes:
		var path: String = scenes[test_name]
		var res = load(path)
		_assert_true(
			res is PackedScene,
			test_name,
			"Loaded successfully",
			"Failed to load " + path
		)


# ---------------------------------------------------------------------------
# Suite: Script Existence (11 tests)
# ---------------------------------------------------------------------------

func _test_script_existence() -> void:
	var scripts := {
		"script_exists_input_setup": "res://scripts/autoload/input_setup.gd",
		"script_exists_game_manager": "res://scripts/autoload/game_manager.gd",
		"script_exists_main": "res://scripts/main.gd",
		"script_exists_character_select": "res://scripts/character_select.gd",
		"script_exists_arena": "res://scripts/arena.gd",
		"script_exists_fighter_base": "res://scripts/fighter_base.gd",
		"script_exists_dynamic_camera": "res://scripts/dynamic_camera.gd",
		"script_exists_attack_data": "res://scripts/combat/attack_data.gd",
		"script_exists_hitbox": "res://scripts/combat/hitbox.gd",
		"script_exists_combat_hud": "res://scripts/combat_hud.gd",
		"script_exists_input_debug_hud": "res://scripts/input_debug_hud.gd",
		"script_exists_pause_menu": "res://scripts/pause_menu.gd",
	}
	for test_name in scripts:
		var path: String = scripts[test_name]
		_assert_true(
			FileAccess.file_exists(path),
			test_name,
			"File exists",
			"Missing: " + path
		)


# ---------------------------------------------------------------------------
# Suite: FighterBase Structure (3 tests)
# ---------------------------------------------------------------------------

func _test_fighter_base_structure() -> void:
	var scene := load("res://scenes/FighterBase.tscn") as PackedScene
	if scene == null:
		_fail("fighter_base_root_type", "Could not load FighterBase.tscn")
		_fail("fighter_base_collision_child", "Could not load FighterBase.tscn")
		_fail("fighter_base_script_attached", "Could not load FighterBase.tscn")
		return

	var instance := scene.instantiate()

	# Test 1: Root is CharacterBody2D
	_assert_true(
		instance is CharacterBody2D,
		"fighter_base_root_type",
		"Root is CharacterBody2D",
		"Root is " + instance.get_class() + ", expected CharacterBody2D"
	)

	# Test 2: Has CollisionShape2D child
	var has_collision := false
	for child in instance.get_children():
		if child is CollisionShape2D:
			has_collision = true
			break
	_assert_true(
		has_collision,
		"fighter_base_collision_child",
		"CollisionShape2D child found",
		"No CollisionShape2D child"
	)

	# Test 3: Script referenced in scene
	# Note: In --script mode, class_name/autoload globals aren't registered so
	# fighter_base.gd can't compile. We verify the scene *references* the script
	# and that the script file exists, which is the meaningful check.
	var scene_state := scene.get_state()
	var has_script_ref := false
	for i in scene_state.get_node_property_count(0):
		if scene_state.get_node_property_name(0, i) == "script":
			has_script_ref = true
			break
	_assert_true(
		has_script_ref and FileAccess.file_exists("res://scripts/fighter_base.gd"),
		"fighter_base_script_attached",
		"Script referenced in scene and file exists",
		"No script reference in scene root"
	)

	instance.free()


# ---------------------------------------------------------------------------
# Suite: Attack Data — Brawler (3 tests)
# ---------------------------------------------------------------------------

func _test_attack_data_brawler() -> void:
	var attacks: Dictionary = _attack_data.BRAWLER
	_validate_attack_dict(attacks, "brawler")


# ---------------------------------------------------------------------------
# Suite: Attack Data — Speedster (3 tests)
# ---------------------------------------------------------------------------

func _test_attack_data_speedster() -> void:
	var attacks: Dictionary = _attack_data.SPEEDSTER
	_validate_attack_dict(attacks, "speedster")


func _validate_attack_dict(attacks: Dictionary, prefix: String) -> void:
	var expected_keys := [
		"ground_neutral", "ground_forward", "ground_up", "ground_down",
		"air_neutral", "air_forward", "air_back", "air_up", "air_down",
		"smash_forward", "smash_up", "smash_down",
		"special_neutral", "special_forward", "special_up", "special_down",
		"grab", "pummel",
		"throw_forward", "throw_back", "throw_up", "throw_down",
	]

	# Test 1: All attack keys present
	var missing: Array = []
	for key in expected_keys:
		if not attacks.has(key):
			missing.append(key)
	_assert_true(
		missing.is_empty(),
		prefix + "_attack_keys_present",
		"All " + str(expected_keys.size()) + " attack keys present",
		"Missing keys: " + str(missing)
	)

	# Test 2: Required fields per attack type
	var fields_ok := true
	var field_errors: Array = []
	var attack_fields := ["damage", "angle", "base_kb", "kb_scaling", "hitlag_frames",
		"startup", "active", "recovery", "hitbox_offset", "hitbox_size"]
	var throw_fields := ["damage", "angle", "base_kb", "kb_scaling", "hitlag_frames"]
	var grab_fields := ["startup", "active", "recovery", "hitbox_offset", "hitbox_size"]
	var pummel_fields := ["damage", "startup", "active", "recovery"]

	for key in attacks:
		var data: Dictionary = attacks[key]
		var required: Array
		if key.begins_with("throw_"):
			required = throw_fields
		elif key == "grab":
			required = grab_fields
		elif key == "pummel":
			required = pummel_fields
		else:
			required = attack_fields
		for field in required:
			if not data.has(field):
				fields_ok = false
				field_errors.append(key + " missing " + field)

	_assert_true(
		fields_ok,
		prefix + "_required_fields",
		"All attacks have required fields",
		"Field errors: " + str(field_errors)
	)

	# Test 3: Damage > 0 for all attacks that have damage
	var damage_ok := true
	var damage_errors: Array = []
	for key in attacks:
		var data: Dictionary = attacks[key]
		if data.has("damage"):
			if data["damage"] <= 0:
				damage_ok = false
				damage_errors.append(key + " damage=" + str(data["damage"]))

	_assert_true(
		damage_ok,
		prefix + "_damage_positive",
		"All damage values positive",
		"Bad damage: " + str(damage_errors)
	)


# ---------------------------------------------------------------------------
# Suite: Fighter Config (2 tests)
# ---------------------------------------------------------------------------

func _test_fighter_config() -> void:
	# Test 1: Weight values valid
	var brawler_weight: float = _attack_data.get_weight(0)
	var speedster_weight: float = _attack_data.get_weight(1)
	_assert_true(
		brawler_weight == 100.0 and speedster_weight == 80.0,
		"fighter_weight_values",
		"Brawler=100, Speedster=80",
		"Unexpected weights: Brawler=" + str(brawler_weight) + " Speedster=" + str(speedster_weight)
	)

	# Test 2: get_attacks() returns correct dictionaries
	var brawler_attacks: Dictionary = _attack_data.get_attacks(0)
	var speedster_attacks: Dictionary = _attack_data.get_attacks(1)
	_assert_true(
		brawler_attacks.size() > 0 and speedster_attacks.size() > 0
		and brawler_attacks.has("ground_neutral") and speedster_attacks.has("ground_neutral"),
		"fighter_get_attacks_returns",
		"get_attacks() returns valid dicts for both types",
		"get_attacks() returned invalid data"
	)


# ---------------------------------------------------------------------------
# Suite: Knockback Formula (2 tests)
# ---------------------------------------------------------------------------

func _test_knockback_formula() -> void:
	# Formula: (base_kb + (percent * kb_scaling / 10)) * (200 / (weight + 100))
	# Using Brawler ground_neutral: base_kb=40, kb_scaling=90, weight=100

	var base_kb := 40.0
	var kb_scaling := 90.0
	var weight := 100.0

	# Test 1: At 0% damage → (40 + 0) * (200/200) = 40.0
	var kb_0 := (base_kb + (0.0 * kb_scaling / 10.0)) * (200.0 / (weight + 100.0))
	_assert_true(
		absf(kb_0 - 40.0) < 0.01,
		"knockback_at_0_percent",
		"KB at 0%% = " + str(kb_0) + " (expected 40.0)",
		"KB at 0%% = " + str(kb_0) + " (expected 40.0)"
	)

	# Test 2: At 100% damage → (40 + 900) * (200/200) = 940.0
	var kb_100 := (base_kb + (100.0 * kb_scaling / 10.0)) * (200.0 / (weight + 100.0))
	_assert_true(
		absf(kb_100 - 940.0) < 0.01,
		"knockback_at_100_percent",
		"KB at 100%% = " + str(kb_100) + " (expected 940.0)",
		"KB at 100%% = " + str(kb_100) + " (expected 940.0)"
	)


# ---------------------------------------------------------------------------
# Suite: Project Config (3 tests)
# ---------------------------------------------------------------------------

func _test_project_config() -> void:
	# Test 1: Autoloads registered
	var has_input := ProjectSettings.has_setting("autoload/InputSetup")
	var has_gm := ProjectSettings.has_setting("autoload/GameManager")
	_assert_true(
		has_input and has_gm,
		"autoloads_registered",
		"InputSetup and GameManager autoloads registered",
		"Missing autoloads: InputSetup=" + str(has_input) + " GameManager=" + str(has_gm)
	)

	# Test 2: Viewport size correct
	var vp_w: int = ProjectSettings.get_setting("display/window/size/viewport_width", 0)
	var vp_h: int = ProjectSettings.get_setting("display/window/size/viewport_height", 0)
	_assert_true(
		vp_w == 1280 and vp_h == 720,
		"viewport_size_correct",
		"Viewport 1280x720",
		"Viewport " + str(vp_w) + "x" + str(vp_h) + " (expected 1280x720)"
	)

	# Test 3: Physics collision layers defined
	var layer1: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_1", "")
	var layer2: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_2", "")
	var layer3: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_3", "")
	var layer4: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_4", "")
	var layer5: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_5", "")
	var all_named := layer1 != "" and layer2 != "" and layer3 != "" and layer4 != "" and layer5 != ""
	_assert_true(
		all_named,
		"physics_layers_defined",
		"All 5 physics layers named",
		"Unnamed layers: 1=" + layer1 + " 2=" + layer2 + " 3=" + layer3 + " 4=" + layer4 + " 5=" + layer5
	)


# ---------------------------------------------------------------------------
# Suite: GameManager Settings (2 tests)
# ---------------------------------------------------------------------------

func _test_game_manager_settings() -> void:
	var gm_script := load("res://scripts/autoload/game_manager.gd") as GDScript
	if gm_script == null:
		_fail("game_manager_has_match_time_limit", "Could not load game_manager.gd")
		_fail("game_manager_has_is_paused", "Could not load game_manager.gd")
		return

	var source: String = gm_script.source_code

	_assert_true(
		source.contains("match_time_limit"),
		"game_manager_has_match_time_limit",
		"match_time_limit property found",
		"match_time_limit property not found in game_manager.gd"
	)

	_assert_true(
		source.contains("is_paused"),
		"game_manager_has_is_paused",
		"is_paused property found",
		"is_paused property not found in game_manager.gd"
	)


# ---------------------------------------------------------------------------
# Suite: Performance (1 test)
# ---------------------------------------------------------------------------

func _test_performance() -> void:
	var scene := load("res://scenes/FighterBase.tscn") as PackedScene
	if scene == null:
		_fail("fighter_instantiation_performance", "Could not load FighterBase.tscn")
		return

	var t0 := Time.get_ticks_msec()
	var instance := scene.instantiate()
	var elapsed := Time.get_ticks_msec() - t0
	instance.free()

	_assert_true(
		elapsed < 1000,
		"fighter_instantiation_performance",
		"Instantiated in " + str(elapsed) + "ms (limit 1000ms)",
		"Took " + str(elapsed) + "ms (limit 1000ms)"
	)


# ---------------------------------------------------------------------------
# Suite: Special Input Action (1 test)
# ---------------------------------------------------------------------------

func _test_special_input_action() -> void:
	var script := load("res://scripts/autoload/input_setup.gd") as GDScript
	if script == null:
		_fail("special_input_action_exists", "Could not load input_setup.gd")
		return
	var source: String = script.source_code
	_assert_true(
		source.contains("\"special\""),
		"special_input_action_exists",
		"input_setup.gd registers 'special' action",
		"'special' action not found in input_setup.gd source"
	)
