extends Area2D

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var timer_2: Timer = $Timer2
@onready var timer_3: Timer = $Timer3
@onready var stats_page: Control = $StatsPage
@onready var credits_page: Control = $CreditsPage

var level_times: Array[float]
var player: PlayerClass
var entered: bool = false
var player_walking: bool = false

func _ready() -> void:
	toggle_visible(stats_page,false)
	toggle_visible(credits_page,false)

func toggle_visible(node: Node, enable: bool) -> void:
	if enable:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	node.visible = enable


func _physics_process(delta: float) -> void:
	if player:
		if not timer_2.is_stopped():
			player.position += Vector2(100,0) * delta/2

func _on_body_entered(body: Node2D) -> void:
	var game_manager: Node = get_tree().root.get_node("MainGame/GameManager")
	level_times = game_manager.level_times
	entered = true
	player = body
	player.in_cutscene = true
	player.state = 0
	
	timer.start()
	#await get_tree().create_timer(1).timeout
	#player.state = 1
	#
	#await get_tree().create_timer(2).timeout
	#player.state = 1
	#toggle_visible(stats_page,true)
	

func get_text() -> void:
	var total_time: float = 0
	var times_text: String = ""
	
	for i in range(level_times.size()):
		if level_times[i] == 0:
			times_text += "no time yet"
		else:
			times_text += (str(int(level_times[i]/60)) + ":" + str(fmod(level_times[i],60)))
		times_text += "\n"
		total_time += level_times[i]
	if total_time == 0:
		times_text += "no time yet"
	else:
		total_time = snappedf(total_time,0.01)
		times_text += (str(int(total_time/60)) + ":" + str(fmod(total_time,60)))
	$StatsPage/RichTextLabel3.text = times_text
	print(level_times)


func _on_next_mouse_entered() -> void:
	$StatsPage/Next.grab_focus()
func _on_quit_mouse_entered() -> void:
	$CreditsPage/Quit.grab_focus()


func _on_next_pressed() -> void:
	toggle_visible(stats_page,false)
	toggle_visible(credits_page,true)


func _on_timer_timeout() -> void:
	player.state = 1
	get_text()
	timer_2.start(2)


func _on_timer_2_timeout() -> void:
	player.state = 0
	timer_3.start(6)


func _on_timer_3_timeout() -> void:
	toggle_visible(stats_page,true)


func _on_quit_pressed() -> void:
	player.global_position = Vector2(3700, -160)
