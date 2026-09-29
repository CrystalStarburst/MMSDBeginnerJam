extends Node

@export var PCam0: PhantomCamera2D
@export var PCam1: PhantomCamera2D
@export var PCam2: PhantomCamera2D
@export var PCam3: PhantomCamera2D
@onready var entity_root: Node2D = %EntityRoot

var current_zones: Array 

func init_camera() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	PCam0.follow_target = player


func _on_zone_0_body_entered(body: Node2D) -> void:
	PCam0.priority = 2

func _on_zone_0_body_exited(body: Node2D) -> void:
	PCam0.priority = 0


func _on_zone_1_body_entered(body: Node2D) -> void:
	PCam1.priority = 2


func _on_zone_1_body_exited(body: Node2D) -> void:
	PCam1.priority = 0


func _on_zone_2_body_entered(body: Node2D) -> void:
	PCam2.priority = 2


func _on_zone_2_body_exited(body: Node2D) -> void:
	PCam2.priority = 0
