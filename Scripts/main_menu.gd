extends Control
@onready var level_root: Node2D = %LevelRoot
const TUTORIAL = preload("res://Scenes/tutorial.tscn")
@onready var player: PlayerClass = %"EntityRoot/Player"
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var start_level_container: VBoxContainer = $CenterContainer/StartLevelContainer
@onready var main_container: VBoxContainer = $CenterContainer/MainContainer

signal start_game(level)

enum Menus {
	Main, 
	Start, 
	Credits
}

var curr_menu: Menus = Menus.Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phantom_camera_2d.priority = 5
	start_level_container.process_mode = Node.PROCESS_MODE_DISABLED
	start_level_container.visible = false

func _on_start_pressed() -> void:
	main_container.process_mode = Node.PROCESS_MODE_DISABLED
	main_container.visible = false
	start_level_container.process_mode = Node.PROCESS_MODE_INHERIT
	start_level_container.visible = true
	curr_menu = Menus.Start

func start_level(level:int) -> void:
	phantom_camera_2d.priority = 0
	start_game.emit(level)
	
func return_to_main() -> void:
	start_level_container.process_mode = Node.PROCESS_MODE_DISABLED
	start_level_container.visible = false
	#credits disable
	#credits visible false
	main_container.process_mode = Node.PROCESS_MODE_INHERIT
	main_container.visible = true

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and curr_menu != Menus.Main:
		return_to_main()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_start_mouse_entered() -> void:
	$CenterContainer/MainContainer/Start.grab_focus()
func _on_credits_mouse_entered() -> void:
	$CenterContainer/MainContainer/Credits.grab_focus()
func _on_quit_mouse_entered() -> void:
	$CenterContainer/MainContainer/Quit.grab_focus()
func _on_tutorial_mouse_entered() -> void:
	$CenterContainer/StartLevelContainer/Tutorial.grab_focus()
func _on_level_1_mouse_entered() -> void:
	$CenterContainer/StartLevelContainer/Level1.grab_focus()
func _on_level_2_mouse_entered() -> void:
	$CenterContainer/StartLevelContainer/Level2.grab_focus()
func _on_level_3_mouse_entered() -> void:
	$CenterContainer/StartLevelContainer/Level3.grab_focus()
func _on_back_mouse_entered() -> void:
	$CenterContainer/StartLevelContainer/StartBack.grab_focus()


func _on_tutorial_pressed() -> void:
	start_level(1)

func _on_level_1_pressed() -> void:
	start_level(2)

func _on_level_2_pressed() -> void:
	start_level(3)

func _on_level_3_pressed() -> void:
	start_level(4)

func _on_start_back_pressed() -> void:
	return_to_main()
