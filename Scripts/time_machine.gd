extends Area2D

signal rewind
signal fastforward

var in_range: bool
var in_event: bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_range = false
		
func _unhandled_key_input(event: InputEvent) -> void:
	if in_range and not in_event:
		print(event)
		if event.is_action_pressed("rewind"):
			rewind.emit()
			animated_sprite_2d.play("Rewind")
			in_event = true
		if event.is_action_pressed("fastforward"):
			fastforward.emit()
			animated_sprite_2d.play("Fastforward")
			in_event = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation != "default":
		animated_sprite_2d.play("default")
		in_event = false
