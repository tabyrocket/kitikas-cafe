extends Control

# References
@onready var name_field: LineEdit = $NameField
@onready var sign_button: Button = $SignButton



func _on_sign_button_pressed() -> void:
	if name_field.text.strip_edges() != "":
		Global.player_name = name_field.text
		print("Name set to: " + Global.player_name)
