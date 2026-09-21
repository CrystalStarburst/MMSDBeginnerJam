extends Area2D
@onready var timer: Timer = $"Timer"
@onready var timerUI: RichTextLabel = get_tree().get_nodes_in_group("UI")[0]

@onready var timeleft: float = timer.wait_time


func _on_body_entered(_body: Node2D) -> void:
	timer.start()


func _on_body_exited(_body: Node2D) -> void:
	print("timer_stopped", timer.time_left)
	timer.stop()
	
func _process(_delta) ->void:
	if not timer.is_stopped():
		timeleft = snappedf(timer.time_left, 0.01)
	timerUI.text = str(timeleft)
