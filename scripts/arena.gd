extends Node2D

## Arena manager — builds the stage, spawns fighters, sets up camera and HUD.

const FighterScene := preload("res://scenes/FighterBase.tscn")

var fighters: Array = []
var dynamic_camera: Camera2D


func _ready() -> void:
	_build_stage()
	_spawn_fighters()
	_setup_camera()
	_setup_hud()


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
	var spawns: Array[Vector2] = [Vector2(-200, -100), Vector2(200, -100)]
	var characters: Array[int] = [GameManager.player1_character, GameManager.player2_character]

	for i in range(2):
		var fighter = FighterScene.instantiate()
		fighter.set("player_id", i + 1)
		fighter.set("fighter_type", characters[i])
		fighter.position = spawns[i]
		add_child(fighter)
		fighters.append(fighter)


# --- Camera ---

func _setup_camera() -> void:
	var cam_script = load("res://scripts/dynamic_camera.gd")
	dynamic_camera = Camera2D.new()
	dynamic_camera.set_script(cam_script)
	dynamic_camera.set("targets", fighters)
	dynamic_camera.global_position = Vector2(0, -60)
	dynamic_camera.zoom = Vector2(1.0, 1.0)
	add_child(dynamic_camera)


# --- Debug HUD ---

func _setup_hud() -> void:
	var hud_script := load("res://scripts/input_debug_hud.gd")
	var canvas := CanvasLayer.new()
	canvas.name = "HUDLayer"

	var hud = Control.new()
	hud.set_script(hud_script)
	hud.name = "InputDebugHUD"
	hud.set("fighters", fighters)

	canvas.add_child(hud)
	add_child(canvas)
