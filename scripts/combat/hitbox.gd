extends Area2D

## Dynamically spawned hitbox. Carries attack metadata.
## Created by fighter during attack active frames, freed on end.

var attack_data: Dictionary = {}
var attacker: CharacterBody2D = null
var has_hit: bool = false  # Prevent multi-hit per swing


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if has_hit:
		return
	# The area we hit is a hurtbox — its parent is the victim fighter
	var victim = area.get_parent()
	if victim == attacker:
		return
	if not victim.has_method("take_hit"):
		return
	has_hit = true
	victim.take_hit(attack_data, attacker)
