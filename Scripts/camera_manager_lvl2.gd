extends Node

@export var PCam0: PhantomCamera2D
@export var PCam1: PhantomCamera2D
@export var PCam2: PhantomCamera2D


func init_camera() -> void:
	PCam0.tween_resource.duration = 0.0

func recall_mode(start: bool) -> void:
	pass

	
func _on_zone_0_body_entered(body: Node2D) -> void:
	PCam0.priority = 2

func _on_zone_0_body_exited(body: Node2D) -> void:
	PCam0.priority = 0
	PCam0.tween_resource.duration = 1.0


func _on_zone_1_body_entered(body: Node2D) -> void:
	PCam1.priority = 2


func _on_zone_1_body_exited(body: Node2D) -> void:
	PCam1.priority = 0
	
	


func _on_secret_area_body_entered(body: Node2D) -> void:
	PCam2.priority = 3



func _on_secret_area_body_exited(body: Node2D) -> void:
	PCam2.priority = 0
