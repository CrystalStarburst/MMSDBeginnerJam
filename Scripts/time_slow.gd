extends Area2D

@export var slowdown: float
@export var radius: float 
@onready var time_slow_collision_2d: CollisionShape2D = $"TimeSlowCollision2D"
@onready var effect_circle: Sprite2D = $"Effect Circle"

func _ready() -> void:
	time_slow_collision_2d.shape.radius = radius
	effect_circle.texture.width = radius*2
	effect_circle.texture.height = radius*2



func _on_body_entered(body: Node2D) -> void:
	print(slowdown)
	Engine.time_scale = slowdown
	body.time_scale = slowdown
		


func _on_body_exited(body: Node2D) -> void:
	Engine.time_scale = 1
	body.time_scale = 1
