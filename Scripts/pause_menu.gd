extends Control

signal quit_level
signal restart_level

@onready var keybinds_page: Control = $CentreContainer/KeybindsPage
@onready var paused_page: Control = $CentreContainer/PausedPage

func toggle_visible(node: Node, enable: bool) -> void:
	if enable:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	node.visible = enable

func _on_resume_mouse_entered() -> void:
	$CentreContainer/PausedPage/VBoxContainer/Resume.grab_focus()
func _on_return_to_main_mouse_entered() -> void:
	$CentreContainer/PausedPage/VBoxContainer/ReturnToMain.grab_focus()
func _on_restart_mouse_entered() -> void:
	$CentreContainer/PausedPage/VBoxContainer/Restart.grab_focus()
func _on_keybinds_mouse_entered() -> void:
	$CentreContainer/PausedPage/VBoxContainer/Keybinds.grab_focus()
func _on_keybinds_back_mouse_entered() -> void:
	$CentreContainer/KeybindsPage/KeybindsBack.grab_focus()



func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_keybinds_pressed() -> void:
	toggle_visible(paused_page, false)
	toggle_visible(keybinds_page, true)

func _on_restart_pressed() -> void:
	restart_level.emit()

func _on_return_to_main_pressed() -> void:
	quit_level.emit()

func _on_keybinds_back_pressed() -> void:
	toggle_visible(keybinds_page, false)
	toggle_visible(paused_page, true)
