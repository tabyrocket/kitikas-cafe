extends Control

func _ready() -> void:
	var bgm = get_node_or_null("/root/BGM")
	if bgm:
		var cute_lofi = load("res://assets/sound/fassounds-cute-kids-lofi-447358.mp3")
		if bgm.stream != cute_lofi:
			bgm.stream = cute_lofi
			bgm.play()
		
		# Ensure volume is reset (it might have been faded out during time skip)
		bgm.volume_db = -20.982

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/outside_scene.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
