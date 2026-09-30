extends Node

@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var pause_layer: CanvasLayer = %PauseLayer
@onready var default_player_camera: PhantomCamera2D = $PhantomCamera2D
@onready var transition_player: AnimationPlayer = %ScreenLayer/ColorRect/AnimationPlayer
@onready var transition_timer: Timer = $TransitionTimer
@onready var mouse_timer: Timer = $MouseTimer

const MAIN_MENU = preload("res://Scenes/main_menu.tscn")
const TUTORIAL = preload("res://Scenes/tutorial.tscn")
const PLAYER = preload("res://Scenes/player.tscn")
const LEVEL1 = preload("res://Scenes/level_1.tscn")
const LEVEL2 = preload("res://Scenes/level_2.tscn")
const LEVEL3 = preload("res://Scenes/level_3.tscn")


var curr_scene: int = -1
var total_time: float
var level_times: Array[float] = [0,0,0,0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready")
	load_level(-1)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		toggle_pause()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("mousevisible")
	else: 
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		

func _on_main_menu_start_game(level) -> void:
	print("start game")
	transition_player.play("Transition")
	await get_tree().create_timer(0.6).timeout
	unload_level()
	load_level(level)
	load_player()


func _on_pause_menu_quit_level() -> void:
	print("quit level")
	transition_player.play("Transition")
	await get_tree().create_timer(0.6).timeout
	unload_level()
	unload_player()
	toggle_pause()
	load_level(-1)


func _on_pause_menu_restart_level() -> void:
	print("restart level")
	transition_player.play("Transition")
	await get_tree().create_timer(0.6).timeout
	unload_player()
	toggle_pause()
	unload_level()
	load_level(curr_scene)
	load_player()


func _on_level_transition(to, time) -> void:
	print("level transition: ", to)
	transition_player.play("Transition")
	if curr_scene != -1:
		if level_times[curr_scene] == 0 or time < level_times[curr_scene]:
			level_times[curr_scene] = snappedf(time,0.01)
			total_time = 0
			for i in range(level_times.size()):
				total_time += level_times[i]
	await get_tree().create_timer(0.6).timeout
	unload_level()
	unload_player()
	load_level(to)
	if to != -1:
		load_player()

	


func toggle_pause() ->void:
	if curr_scene != -1:
		get_tree().paused = not get_tree().paused
		pause_layer.get_child(0).visible = not pause_layer.get_child(0).visible

	
	
func load_player() -> void:
	var player_scene = PLAYER.instantiate()
	entity_root.add_child(player_scene)
	var player = entity_root.get_child(0)
	player.position = level_root.get_child(0).get_node("WorldSpawn").position
	default_player_camera.follow_target = player
	level_root.get_child(0).get_node("CameraManager").init_camera()
	player.recall.connect(_on_player_recall)
	if curr_scene == 0:
		player.in_tutorial = true
	else:
		player.in_tutorial = false
	print("played loaded")
	


func unload_player() -> void:
	entity_root.get_child(0).queue_free()
	entity_root.remove_child(entity_root.get_child(0))
	print("player unloaded")


func load_level(idx: int) -> void:
	var new_level_scene: Node
	match idx:
		-1: 
			new_level_scene = MAIN_MENU.instantiate()
		0: 
			new_level_scene = TUTORIAL.instantiate()
		1:
			new_level_scene = LEVEL1.instantiate()
		2:
			new_level_scene = LEVEL2.instantiate()
		3:
			new_level_scene = LEVEL3.instantiate()
				
	level_root.add_child(new_level_scene)
	var new_level_node = level_root.get_child(0)
	
	if idx == -1:
		new_level_node.start_game.connect(_on_main_menu_start_game)
	else:
		new_level_node.get_node("LevelTransition").level_transition.connect(_on_level_transition)
	
	curr_scene = idx


func unload_level() -> void:
	level_root.get_child(0).queue_free()
	level_root.remove_child(level_root.get_child(0))

func _on_player_recall(start: bool) ->void:
	level_root.get_child(0).get_node("CameraManager").recall_mode(start)
	
