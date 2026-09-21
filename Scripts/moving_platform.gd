extends AnimatableBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var move_vector: Vector2
const move_speed = 100.0

func _ready() -> void:
	var move_duration: float = move_vector.length() / move_speed
	var anim: Animation = animation_player.get_animation("Movement").duplicate()
	var track_idx: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, ".:position")
	anim.track_insert_key(track_idx, 0.0, position)
	anim.track_insert_key(track_idx, move_duration , position+move_vector)
	anim.length = move_duration
	var library = animation_player.get_animation_library("")
	var animname = "Movement_" + str(get_instance_id())
	library.add_animation(animname, anim)
	
	animation_player.play(animname)
	print("yes")
	
