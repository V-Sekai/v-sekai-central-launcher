extends VBoxContainer

var plugin: Node = null
var gpm: GodotPackageManager = null

@onready
var search_element: LineEdit = %Search
@onready
var results_element: VBoxContainer = %Results

const DEBOUNCE_TICKS: int = 1000
var _last_debounce_ticks: int = Time.get_ticks_msec()

## Needed to prevent DOSing NPM if someone were to mash the enter key.
var _last_search_text := ""

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _ready() -> void:
	var search_bar := %Search as LineEdit
	search_bar.text_changed.connect(func(text: String) -> void:
		var new_ticks := Time.get_ticks_msec()
		if new_ticks - _last_debounce_ticks > 1000:
			_search_npm(text)
		_last_debounce_ticks = Time.get_ticks_msec()
	)
	search_bar.text_submitted.connect(func(text: String) -> void:
		_last_debounce_ticks = Time.get_ticks_msec()
		
		_search_npm(text)
	)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _search_npm(text: String) -> void:
	if text == _last_search_text:
		return
	_last_search_text = text
	
	var results: Array = await GodotPackageManager.Npm.search(text)
	
	for child in results_element.get_children():
		child.queue_free()

	for i in results:
		var data: Dictionary = i.get("package", {})
		if data.is_empty():
			printerr("Received empty data from npm search: %s" % text)
			continue
		
		var button = Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = data.get("name", "No name") + ": " + data.get("description", "No description")
		
		button.pressed.connect(_on_button_pressed.bind(data))
		
		results_element.add_child(button)


func _on_button_pressed(data: Dictionary) -> void:
	if not data.has("version") or not data.has("name"):
		return
	var entry_name = data["version"]
	
	if FileAccess.file_exists("res://godot.package"):
		var file = FileAccess.open("res://godot.package", FileAccess.READ)
		var content = file.get_as_text()
		
		if content.find(entry_name) == -1:
			var packages: Dictionary = JSON.parse_string(file.get_as_text())
			file = FileAccess.open("res://godot.package", FileAccess.WRITE)
			packages[data["name"]] = entry_name
			file.store_string(JSON.stringify(packages))
		file.close()

			
#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

