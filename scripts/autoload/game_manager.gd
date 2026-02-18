extends Node

## Stores selected character indices (0 = Brawler, 1 = Speedster)
var player1_character: int = 0
var player2_character: int = 1

## Combat settings
var stock_count: int = 3
var last_winner: int = 0  # 0 = none, 1 = P1, 2 = P2
var training_mode: bool = false


func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
