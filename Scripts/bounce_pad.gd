extends Area2D
@onready var player: PlayerClass = get_tree().get_first_node_in_group("Player")





func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.velocity = player.JUMP_VELOCITY * transform.y
		print(player.velocity, transform.y)
	print(body)
	print(player)
