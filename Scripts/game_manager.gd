extends Node

@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var pause_layer: CanvasLayer = %PauseLayer
@onready var default_player_camera: PhantomCamera2D = $PhantomCamera2D

const MAIN_MENU = preload("res://Scenes/main_menu.tscn")
const TUTORIAL = preload("res://Scenes/tutorial.tscn")
const PLAYER = preload("res://Scenes/player.tscn")
const LEVEL1 = preload("res://Scenes/level_1.tscn")
const LEVEL2 = preload("res://Scenes/level_2.tscn")
const LEVEL3 = preload("res://Scenes/level_3.tscn")


var curr_scene: int = 0
var total_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready")
	load_level(0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		toggle_pause()
		

func _on_main_menu_start_game(level) -> void:
	print("start game")
	unload_level()
	load_level(level)
	load_player()


func _on_pause_menu_quit_level() -> void:
	print("quit level")
	unload_level()
	unload_player()
	toggle_pause()
	load_level(0)


func _on_pause_menu_restart_level() -> void:
	print("restart level")
	unload_player()
	toggle_pause()
	unload_level()
	load_level(curr_scene)
	load_player()


func _on_level_transition(to) -> void:
	print("level transition: ", to)
	unload_level()
	load_level(to)
	unload_player()
	load_player()

	


func toggle_pause() ->void:
	if curr_scene != 0:
		get_tree().paused = not get_tree().paused
		pause_layer.get_child(0).visible = not pause_layer.get_child(0).visible

#func load_main_menu() ->void:
	#var main_menu_scene = MAIN_MENU.instantiate()
	#level_root.add_child(main_menu_scene)
	#var main_menu_node = level_root.get_child(0)
	#main_menu_node.start_game.connect(_on_main_menu_start_game)
	#curr_scene = 0
	
	
func load_player() -> void:
	var player_scene = PLAYER.instantiate()
	entity_root.add_child(player_scene)
	var player = entity_root.get_child(0)
	player.position = level_root.get_child(0).get_node("WorldSpawn").position
	default_player_camera.follow_target = player
	level_root.get_child(0).get_node("CameraManager").init_camera()
	player.recall.connect(_on_player_recall)
	
	print("played loaded")
	


func unload_player() -> void:
	entity_root.get_child(0).queue_free()
	entity_root.remove_child(entity_root.get_child(0))
	print("player unloaded")


func load_level(idx: int) -> void:
	var new_level_scene: Node
	match idx:
		0: 
			new_level_scene = MAIN_MENU.instantiate()
		1: 
			new_level_scene = TUTORIAL.instantiate()
		2:
			new_level_scene = LEVEL1.instantiate()
		3:
			new_level_scene = LEVEL2.instantiate()
		4:
			new_level_scene = LEVEL3.instantiate()
				
	level_root.add_child(new_level_scene)
	var new_level_node = level_root.get_child(0)
	
	if idx == 0:
		new_level_node.start_game.connect(_on_main_menu_start_game)
	else:
		new_level_node.get_node("LevelTransition").level_transition.connect(_on_level_transition)
	
	curr_scene = idx


func unload_level() -> void:
	level_root.get_child(0).queue_free()
	level_root.remove_child(level_root.get_child(0))

func _on_player_recall(start: bool) ->void:
	level_root.get_child(0).get_node("CameraManager").recall_mode(start)
	
