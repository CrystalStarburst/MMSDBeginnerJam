extends Control


@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var texture_rect: TextureRect = $TextureRect
@onready var game_name: Label = $GameName
@onready var jam_name: Label = $JamName

@onready var main_container: VBoxContainer = $CenterContainer/MainContainer
@onready var start_level_container: VBoxContainer = $CenterContainer/StartLevelContainer
@onready var info_container: VBoxContainer = $CenterContainer/InfoContainer

@onready var stats_page: Control = $CenterContainer/StatsPage
@onready var keybinds_page: Control = $CenterContainer/KeybindsPage
@onready var credits_page: Control = $CenterContainer/CreditsPage

signal start_game(level)

enum Menus {
	Main, 
	Start, 
	Info,
	Stats,
	Keybinds,
	Credits
}

var curr_menu: Menus = Menus.Main

var level_times: Array[float]
var total_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phantom_camera_2d.priority = 5
	return_to_info()
	return_to_main()

func start_level(level:int) -> void:
	phantom_camera_2d.priority = 0
	start_game.emit(level)
	
func return_to_main() -> void:
	toggle_visible(start_level_container, false)
	toggle_visible(info_container, false)
	toggle_visible(main_container, true)
	texture_rect.visible = false
	game_name.visible = true
	jam_name.visible = true
	$CenterContainer/MainContainer/Start.grab_focus()
	curr_menu = Menus.Main

func toggle_visible(node: Node, enable: bool) -> void:
	if enable:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	node.visible = enable

func main_buttons(node: Node):
	toggle_visible(main_container, false)
	toggle_visible(node, true)
	texture_rect.visible = true
	game_name.visible = false
	jam_name.visible = false
#
#func _unhandled_key_input(event: InputEvent) -> void:
	#if event.is_action_pressed("escape"):
		#match curr_menu: 
			#Menus.Main:
				#pass
			#[Menus.Start, Menus.Info]:
				#return_to_main()
			#[Menus.Stats, Menus.Keybinds, Menus.Credits]:
				#return_to_info()
				#

func _on_start_pressed() -> void:
	main_buttons(start_level_container)
	$CenterContainer/StartLevelContainer/Tutorial.grab_focus()
	curr_menu = Menus.Start

func _on_info_pressed() -> void:
	main_buttons(info_container)
	$CenterContainer/InfoContainer/Stats.grab_focus()
	curr_menu = Menus.Info

func _on_quit_pressed() -> void:
	get_tree().quit()


func return_to_info() -> void:
	toggle_visible(stats_page, false)
	toggle_visible(keybinds_page, false)
	toggle_visible(credits_page, false)
	toggle_visible(info_container, true)
	curr_menu = Menus.Info
	$CenterContainer/InfoContainer/Stats.grab_focus()
	print("returned to info")

func info_buttons(node: Node):
	toggle_visible(info_container, false)
	toggle_visible(node, true)

func _on_start_mouse_entered() -> void:
	$CenterContainer/MainContainer/Start.grab_focus()
func _on_info_mouse_entered() -> void:
	$CenterContainer/MainContainer/Info.grab_focus()
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
func _on_stats_mouse_entered() -> void:
	$CenterContainer/InfoContainer/Stats.grab_focus()
func _on_keybinds_mouse_entered() -> void:
	$CenterContainer/InfoContainer/Keybinds.grab_focus()
func _on_credits_mouse_entered() -> void:
	$CenterContainer/InfoContainer/Credits.grab_focus()
func _on_info_back_mouse_entered() -> void:
	$CenterContainer/InfoContainer/InfoBack.grab_focus()


func _on_tutorial_pressed() -> void:
	start_level(0)

func _on_level_1_pressed() -> void:
	start_level(1)

func _on_level_2_pressed() -> void:
	start_level(2)

func _on_level_3_pressed() -> void:
	start_level(3)

func _on_start_back_pressed() -> void:
	return_to_main()


func _on_stats_pressed() -> void:
	var game_manager: Node = get_tree().root.get_node("MainGame/GameManager")
	var times_text: String = ""
	for i in range(game_manager.level_times.size()):
		if game_manager.level_times[i] == 0:
			times_text += "no time yet"
		else:
			times_text += (str(int(game_manager.level_times[i]/60)) + ":" + str(fmod(game_manager.level_times[i],60)))
		times_text += "\n"
	if game_manager.total_time == 0:
		times_text += "no time yet"
	else:
		total_time = snappedf(total_time,0.01)
		times_text += (str(int(total_time/60)) + ":" + str(fmod(total_time,60)))
	$CenterContainer/StatsPage/RichTextLabel3.text = times_text
	info_buttons(stats_page)
	curr_menu = Menus.Stats

func _on_keybinds_pressed() -> void:
	info_buttons(keybinds_page)
	curr_menu = Menus.Keybinds

func _on_credits_pressed() -> void:
	info_buttons(credits_page)
	curr_menu = Menus.Credits

func _on_info_back_pressed() -> void:
	return_to_main()


func _on_stats_back_mouse_entered() -> void:
	$CenterContainer/StatsPage/StatsBack.grab_focus()

func _on_stats_back_pressed() -> void:
	return_to_info()


func _on_keybinds_back_mouse_entered() -> void:
	$CenterContainer/KeybindsPage/KeybindsBack.grab_focus()

func _on_keybinds_back_pressed() -> void:
	return_to_info()


func _on_credits_back_mouse_entered() -> void:
	$CenterContainer/CreditsPage/CreditsBack.grab_focus()


func _on_credits_back_pressed() -> void:
	return_to_info()
