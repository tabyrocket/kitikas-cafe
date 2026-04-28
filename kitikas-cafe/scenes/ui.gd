extends CanvasLayer

@onready var pause_menu: ColorRect = $Root/PauseMenu
@onready var chatbox_left: TextureRect = $Root/ChatboxLeft

func _ready() -> void:
	chatbox_left.visible = false
	pause_menu.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = not pause_menu.visible


func _on_pause_button_pressed() -> void:
	pause_menu.visible = not pause_menu.visible
