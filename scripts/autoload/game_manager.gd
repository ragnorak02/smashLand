extends Node

## Stores selected character indices (0 = Brawler, 1 = Speedster)
var player1_character: int = 0
var player2_character: int = 1

## Combat settings
var stock_count: int = 3
var match_time_limit: int = 300  # seconds (0 = infinite)
var last_winner: int = 0  # 0 = none, 1 = P1, 2 = P2
var training_mode: bool = false

## Pause state
var is_paused: bool = false


func change_scene(path: String) -> void:
	is_paused = false
	get_tree().change_scene_to_file(path)
