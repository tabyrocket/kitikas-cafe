extends Control

# References
@onready var cafe_sign_button: Button = $Cafe/CafeSignButton
@onready var zoomed_in_cafe: TextureRect = $ZoomedInCafe
@onready var job_chatbox_timer: Timer = $JobChatboxTimer
@onready var chatbox_left: TextureRect = $UI/Root/ChatboxLeft
@onready var dialogue: RichTextLabel = $UI/Root/ChatboxLeft/Dialogue

func _ready() -> void:
	zoomed_in_cafe.visible = false
	chatbox_left.visible = false


func _on_cafe_sign_button_pressed() -> void:
	zoomed_in_cafe.visible = true
	job_chatbox_timer.start()


func _on_job_chatbox_timer_timeout() -> void:
	dialogue.text = "MC: *shivers* S-should I try get a j*b...? I'll try apply I guess. Empl*yment can't be that bad, right?"
	chatbox_left.visible = true
