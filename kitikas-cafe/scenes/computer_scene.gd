extends Control

# References
@onready var ui: CanvasLayer = $UI
@onready var mc_house: TextureRect = $MCHouse
@onready var laptop_screen: TextureRect = $LaptopScreen
@onready var laptop_email_1: TextureRect = $LaptopEmail1
@onready var laptop_email_2: TextureRect = $LaptopEmail2
@onready var acceptance_letter: TextureRect = $AcceptanceLetter
@onready var dialogue_cooldown: Timer = $DialogueCooldown
@onready var dialogue: RichTextLabel = $UI/Root/ChatboxLeft/Dialogue
@onready var speaker: RichTextLabel = $UI/Root/ChatboxLeft/Speaker
@onready var chatbox_left: TextureRect = $UI/Root/ChatboxLeft

var can_move_on: bool = false
var current_image: int = 0
var images: Array = []
var dialogue_strings: Array = [
	"Me on my puter",
	"New email? Who could that be?",
	"Oh, the cafe application?!?! I'm so nervous...",
	"No way... did I do it?!?!",
	"I'M EMPL*YED?!? HOLY I JUST SHAT MYSELF, HOW AM I GONNA BE CHRONICALLY ONLINE NOW???"
]


func _on_dialogue_button_pressed():
	# If still typing, skip to end first
	if ui.is_typing():
		ui.typewriter_skip()
	# Otherwise advance to next image
	elif can_move_on and current_image < (images.size() - 1):
		current_image += 1
		update_img()

func _ready() -> void:
	images = [mc_house, laptop_screen, laptop_email_1, laptop_email_2, acceptance_letter]
	update_img()
	ui.get_node("Root/ChatboxLeft/DialogueButton").pressed.connect(_on_dialogue_button_pressed)
	

func update_img() -> void:
	chatbox_left.visible = false
	can_move_on = false
	dialogue_cooldown.start()
	
	# Background
	for img in images:
		img.visible = false
	images[current_image].visible = true

func _on_dialogue_cooldown_timeout() -> void:
	# Dialogue
	speaker.text = Global.player_name
	ui.typewriter(dialogue, dialogue_strings[current_image])
	chatbox_left.visible = true
	can_move_on = true
