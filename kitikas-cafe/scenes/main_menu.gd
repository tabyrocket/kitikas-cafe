extends Control



func _on_start_button_pressed() -> void:
	print('hi')
	get_tree().change_scene_to_file("res://scenes/outside_scene.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
