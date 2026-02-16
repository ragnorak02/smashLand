extends Node

## Entry point — immediately transitions to character select.


func _ready() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/CharacterSelect.tscn")
