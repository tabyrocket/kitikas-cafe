extends Control

# References
@onready var name_field: LineEdit = $NameField
@onready var sign_button: Button = $SignButton
@onready var two_days_later: TextureRect = $TwoDaysLater
@onready var two_days_timer: Timer = $TwoDaysTimer
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	two_days_later.visible = false

func _on_sign_button_pressed() -> void:
	if name_field.text.strip_edges() != "":
		Global.player_name = name_field.text.strip_edges()
		print("Name set to: " + Global.player_name)
		
		# Hide UI immediately
		ui.get_node("Root/ChatboxLeft").visible = false
		ui.get_node("Root/ChatboxRight").visible = false
		ui.main_dialogue_button.visible = false
		
		two_days_later.modulate.a = 0.0
		two_days_later.visible = true
		var tween = create_tween()
		tween.tween_property(two_days_later, "modulate:a", 1.0, 1.0)
		await tween.finished
		two_days_timer.start()


func _on_two_days_timer_timeout() -> void:
	var black = ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.modulate.a = 0.0
	ui.get_node("Root").add_child(black)
	
	var tween = create_tween()
	tween.tween_property(black, "modulate:a", 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/computer_scene.tscn")
