extends Area2D
@onready var player: PlayerClass = get_tree().get_first_node_in_group("Player")
@onready var bounce_sprite_2d: AnimatedSprite2D = $BounceSprite2D





func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.bouncepad(transform.y)
		
			
		print(player.velocity, transform.y)
		bounce_sprite_2d.play("Bounce")
	
