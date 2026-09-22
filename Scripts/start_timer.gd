extends Area2D


@export var duration: float
@export var camera_position: Vector2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.level_timer = duration
		body.level_started = true
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.level_started = false
