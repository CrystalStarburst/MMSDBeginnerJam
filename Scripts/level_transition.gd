extends Area2D

signal level_transition (to)
@export var next_level: int



func _on_body_entered(body: Node2D) -> void:
	level_transition.emit(next_level)
