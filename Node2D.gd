extends Control

@export_file("*.exe") var wp_binary
@export_global_dir var godot_project

func _ready():
	connect("tree_exiting", Callable(self, "_stop_wallpaper"))

func _on_Button2_pressed():
	var args = ["--path", godot_project]
# The project automatically enables wallpaper mode.
	OS.create_instance(args)


func _on_Off_pressed():
	_stop_wallpaper()


func _stop_wallpaper():
	var args = ["kill", "--index", "0"]
	var output : Array = [].duplicate()
	OS.execute(wp_binary, args, output)
	print(output)
