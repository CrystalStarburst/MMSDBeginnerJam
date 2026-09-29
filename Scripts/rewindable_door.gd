extends AnimatableBody2D

@export var time_machine: Area2D
@export var init_broken: bool
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var broken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(time_machine)
	time_machine.rewind.connect(_on_time_machine_rewind)
	time_machine.fastforward.connect(_on_time_machine_fastforward)
	if init_broken:
		animated_sprite_2d.play("break")
		animation_player.play("Breaking")
		broken = true
	else:
		animation_player.play("RESET")
		

func _on_time_machine_rewind() ->void:
	if broken:
		animated_sprite_2d.play("reform")
		animation_player.play("Reforming")
		broken = false

func _on_time_machine_fastforward() ->void:
	if not broken:
		animated_sprite_2d.play("break")
		animation_player.play("Breaking")
		broken = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "reform":
		animated_sprite_2d.play("default")
