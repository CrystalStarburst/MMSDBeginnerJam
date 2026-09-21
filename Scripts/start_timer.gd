extends Area2D
#@onready var timer: Timer = $"Timer"
#@onready var timerUI: RichTextLabel = get_tree().get_nodes_in_group("UI")[0]
#@onready var timeleft: float = timer.wait_time

@export var duration: float


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#if timer.paused:
			#timer.paused = false
		#else:
			#timer.start()
		body.level_timer = duration
	
		body.level_started = true
		

func _on_body_exited(body: Node2D) -> void:
	#print("timer_stopped", timer.time_left)
	#timer.paused = true
	if body.is_in_group("Player"):
		body.level_started = false
	
#func _process(_delta) ->void:
	#if not timer.is_stopped(): 
		#timeleft = snappedf(timer.time_left, 0.01)
	#timerUI.text = str(timeleft)
