extends Area2D


@export var duration: float
@export var camera_position: Vector2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.level_started = true
		body.get_rewind_point()
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.level_started = false
		body.past_pos.clear()
		body.past_vel.clear()
