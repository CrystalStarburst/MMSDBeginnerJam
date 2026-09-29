extends Control

signal quit_level
signal restart_level

func _on_resume_mouse_entered() -> void:
	$CentreContainer/VBoxContainer/Resume.grab_focus()


func _on_return_to_main_mouse_entered() -> void:
	$CentreContainer/VBoxContainer/ReturnToMain.grab_focus()


func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false
	


func _on_return_to_main_pressed() -> void:
	quit_level.emit()


func _on_restart_mouse_entered() -> void:
	$CentreContainer/VBoxContainer/Restart.grab_focus()


func _on_restart_pressed() -> void:
	restart_level.emit()
