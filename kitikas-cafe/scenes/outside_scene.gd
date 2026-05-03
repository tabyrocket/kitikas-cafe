extends Control

# References
@onready var ui: CanvasLayer = $UI
@onready var cafe_sign_button: Button = $Cafe/CafeSignButton
@onready var zoomed_in_cafe: TextureRect = $ZoomedInCafe
@onready var job_chatbox_timer: Timer = $JobChatboxTimer
@onready var chatbox_left: TextureRect = $UI/Root/ChatboxLeft
@onready var dialogue: RichTextLabel = $UI/Root/ChatboxLeft/Dialogue
@onready var speaker: RichTextLabel = $UI/Root/ChatboxLeft/Speaker

var done: bool = false

func _on_dialogue_button_pressed():
	# Skip typewriter if still typing
	if ui.is_typing():
		ui.typewriter_skip()
		return
	if done == true:
		get_tree().change_scene_to_file("res://scenes/application_form.tscn")

func _ready() -> void:
	zoomed_in_cafe.visible = false
	chatbox_left.visible = false
	ui.get_node("Root/ChatboxLeft/DialogueButton").pressed.connect(_on_dialogue_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		if chatbox_left.visible:
			_on_dialogue_button_pressed()


func _on_cafe_sign_button_pressed() -> void:
	zoomed_in_cafe.visible = true
	job_chatbox_timer.start()


func _on_job_chatbox_timer_timeout() -> void:
	speaker.text = "MC"
	chatbox_left.visible = true
	done = true
	ui.typewriter(dialogue, "*shivers* S-should I try get a j*b...? I'll try apply I guess. Empl*yment can't be that bad, right?")
