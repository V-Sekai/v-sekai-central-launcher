extends Control

@export_global_dir var godot_project

var pid = -1

func _on_Button2_pressed():
	var args = ["--path", godot_project]
	pid = OS.create_instance(args)


func _on_Off_pressed():
	_stop_pid()


func _stop_pid():
	OS.kill(pid)
