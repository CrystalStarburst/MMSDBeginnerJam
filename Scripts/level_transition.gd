extends Area2D

signal level_transition (to)
@export var next_level: int
@export var ending_area: Area2D

var time: float = 0.0

func _physics_process(delta: float) -> void:
	if ending_area:
		if not ending_area.entered:
			time += delta
		elif ending_area.level_times[3] == 0 or time < ending_area.level_times[3]:
			ending_area.level_times[3] = snappedf(time, 0.01)
			print("stopped")
	else:
		time += delta
	if Engine.get_physics_frames() % 60 == 0:
		print(ending_area.level_times)

func _on_body_entered(body: Node2D) -> void:
	level_transition.emit(next_level, time)
	print(time)
