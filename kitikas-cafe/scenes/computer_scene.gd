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
@onready var two_days_timer: Timer = $TwoDaysTimer
@onready var two_days_later: TextureRect = $TwoDaysLater

var can_move_on: bool = false
var current_image: int = 0
var images: Array = []
var dialogue_strings: Array = [
	"Hmmm...",
	"Oh! New email.",
	"My application! I wonder how I did...",
	"Did I get it???",
	"I'M EMPL*YED?!? HOLY I JUST SHAT MYSELF, HOW AM I GONNA BE CHRONICALLY ONLINE NOW???",
	"AND I START IN 2 DAYS???"
]


func _on_dialogue_button_pressed():
	# If still typing, skip to end first
	if ui.is_typing():
		ui.typewriter_skip()
	# Otherwise advance to next image
	elif can_move_on and current_image < (images.size() - 1):
		current_image += 1
		update_img()
	elif current_image == images.size() - 1:
		transition()

func _ready() -> void:
	two_days_later.visible = false
	images = [mc_house, laptop_screen, laptop_email_1, laptop_email_2, acceptance_letter, acceptance_letter]
	update_img()
	ui.get_node("Root/ChatboxLeft/DialogueButton").pressed.connect(_on_dialogue_button_pressed)
	ui.main_dialogue_button.pressed.connect(_on_dialogue_button_pressed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		if chatbox_left.visible:
			_on_dialogue_button_pressed()
	

func update_img() -> void:
	chatbox_left.visible = false
	ui.main_dialogue_button.visible = false
	can_move_on = false
	dialogue_cooldown.start()
	
	# Background
	for img in images:
		img.visible = false
	images[current_image].visible = true

func transition() -> void:
	two_days_later.visible = true
	two_days_timer.start()
	chatbox_left.visible = false
	ui.main_dialogue_button.visible = false

func _on_dialogue_cooldown_timeout() -> void:
	# Dialogue
	speaker.text = Global.player_name
	ui.typewriter(dialogue, dialogue_strings[current_image])
	chatbox_left.visible = true
	ui.main_dialogue_button.visible = true
	can_move_on = true


func _on_two_days_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/first_day.tscn")
