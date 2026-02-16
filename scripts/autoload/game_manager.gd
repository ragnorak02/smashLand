extends Node

## Stores selected character indices (0 = Brawler, 1 = Speedster)
var player1_character: int = 0
var player2_character: int = 1


func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
