extends HTTPRequest


func _ready() -> void:
	var http_request : HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	var error : int = http_request.request("https://api.github.com/repos/V-sekai/mediapipe/releases")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	else:
		connect("request_completed", Callable(self, "_on_request_completed"))


func _http_request_completed(result, response_code, headers, body) -> void:
	var json : JSON = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response : Array = json.get_data()
	if not response.size():
		return
	var elem_response : Dictionary = response[0]
	if not elem_response.has("assets"):
		return
	var assets : Array = elem_response.assets
	if not assets.size():
		return
	var elem_asset : Dictionary = assets[0]
	if not elem_asset.has("browser_download_url"):
		return
	var url : String = elem_asset["browser_download_url"]
	print(url)
	request(url)


func _on_request_completed(result, response_code, headers, body) -> void:
	var buffer = body
	var save : File = File.new()
	save.open("exe.zip", File.WRITE)
	save.store_buffer(buffer)
	print("_on_request_completed")
