extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("died")
	if body.is_in_group("Player"):
		body.start_rewind()
