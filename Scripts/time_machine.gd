extends Area2D

signal rewind
signal fastforward

var in_range: bool
var in_event: bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var r_key: Sprite2D = $R_key
@onready var f_key: Sprite2D = $F_key





func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_range = true
		r_key.show()
		r_key.modulate = Color(0.8,0.8,0.8,0.9)
		f_key.show()
		f_key.modulate = Color(0.8,0.8,0.8,0.9)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_range = false
		r_key.hide()
		f_key.hide()
		
func _unhandled_key_input(event: InputEvent) -> void:
	if in_range and not in_event:
		if event.is_action_pressed("rewind"):
			rewind.emit()
			animated_sprite_2d.play("Rewind")
			in_event = true
			f_key.modulate = Color(0.7,0.7,0.7,0.7)
			r_key.modulate = Color(1,1,1,1)
		if event.is_action_pressed("fastforward"):
			fastforward.emit()
			animated_sprite_2d.play("Fastforward")
			in_event = true	
			r_key.modulate = Color(0.7,0.7,0.7,0.7)
			f_key.modulate = Color(1,1,1,1)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation != "default":
		animated_sprite_2d.play("default")
		in_event = false
		r_key.modulate = Color(0.8,0.8,0.8,0.9)
		f_key.modulate = Color(0.8,0.8,0.8,0.9)
