extends Node

@export var PCam0: PhantomCamera2D
@onready var GCam0: PhantomCamera2D = $Zone0/GroupCamera2D
@export var PCam1: PhantomCamera2D
@export var PCam2: PhantomCamera2D
@export var PCam3: PhantomCamera2D
@onready var entity_root: Node2D = %EntityRoot

var curr_pcam:int = -1

func init_camera() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	PCam0.tween_resource.duration = 0.0
	PCam0.follow_target = player
	GCam0.follow_targets = [player, player.get_node("RewindPoint")]

func recall_mode(start: bool) -> void:
	match curr_pcam:
		0: 
			if start:
				GCam0.priority = 3
			else:
				GCam0.priority = 0

	
func _on_zone_0_body_entered(body: Node2D) -> void:
	PCam0.priority = 2
	curr_pcam = 0

func _on_zone_0_body_exited(body: Node2D) -> void:
	PCam0.priority = 0
	curr_pcam = -1
	PCam0.tween_resource.duration = 1.0


func _on_zone_1_body_entered(body: Node2D) -> void:
	PCam1.priority = 2
	curr_pcam = 1


func _on_zone_1_body_exited(body: Node2D) -> void:
	PCam1.priority = 0
	curr_pcam = -1


func _on_zone_2_body_entered(body: Node2D) -> void:
	PCam2.priority = 2
	curr_pcam = 2


func _on_zone_2_body_exited(body: Node2D) -> void:
	PCam2.priority = 0
	curr_pcam = -1
