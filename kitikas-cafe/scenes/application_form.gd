extends Control

# References
@onready var name_field: LineEdit = $NameField
@onready var sign_button: Button = $SignButton
@onready var two_days_later: TextureRect = $TwoDaysLater
@onready var two_days_timer: Timer = $TwoDaysTimer

func _ready() -> void:
	two_days_later.visible = false

func _on_sign_button_pressed() -> void:
	if name_field.text.strip_edges() != "":
		Global.player_name = name_field.text.strip_edges()
		print("Name set to: " + Global.player_name)
		two_days_later.visible = true
		two_days_timer.start()


func _on_two_days_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/computer_scene.tscn")
