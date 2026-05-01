extends Control

# References
@onready var outside: TextureRect = $Backgrounds/Outside
@onready var inside: TextureRect = $Backgrounds/Inside
@onready var character_left: TextureRect = $CharacterLeft
@onready var character_right: TextureRect = $CharacterRight
@onready var character_extra: TextureRect = $CharacterExtra

@onready var ui: CanvasLayer = $UI
@onready var chatbox_left: TextureRect = $UI/Root/ChatboxLeft
@onready var dialogue_left: RichTextLabel = $UI/Root/ChatboxLeft/Dialogue
@onready var speaker_left: RichTextLabel = $UI/Root/ChatboxLeft/Speaker
@onready var chatbox_right: TextureRect = $UI/Root/ChatboxRight
@onready var dialogue_right: RichTextLabel = $UI/Root/ChatboxRight/Dialogue2
@onready var speaker_right: RichTextLabel = $UI/Root/ChatboxRight/Speaker2

@onready var choice_a_btn: Button = $UI/Root/ChoiceA
@onready var choice_b_btn: Button = $UI/Root/ChoiceB

var step: int = 0
var steps: Array = []
var waiting_for_choice: bool = false

func _ready() -> void:
	outside.visible = true
	inside.visible = false
	character_left.visible = false
	character_right.visible = false
	character_extra.visible = false
	choice_a_btn.visible = false
	choice_b_btn.visible = false

	ui.get_node("Root/ChatboxLeft/DialogueButton").pressed.connect(_on_dialogue_button_pressed)
	ui.get_node("Root/ChatboxRight/DialogueButton2").pressed.connect(_on_dialogue_button_pressed)
	choice_a_btn.pressed.connect(_on_choice_a)
	choice_b_btn.pressed.connect(_on_choice_b)

	var mc = Global.player_name
	build_steps(mc)
	show_step()

func build_steps(mc: String) -> void:
	steps = [
		# --- Outside ---
		{"bg": "outside", "side": "left", "speaker": mc, "sprite": "mc_default",
		 "text": "Alright, here goes nothing…"},

		# --- Inside, meet Kitika ---
		{"bg": "inside", "side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "right_sprite": "kitika_default", "left_sprite": "mc_default", "show_left": true,
		 "text": "Hiya! You must be " + mc + "! It's so nice to meet you. How are you?"},

		# --- Choice ---
		{"choice": true,
		 "a_text": "I'm doing good, thanks. How about you? You must be Kitika?",
		 "b_text": "No, that's not me, must be the wrong person. Weirdo."},
	]
	# Branch steps are inserted dynamically after choice

func _on_choice_a() -> void:
	waiting_for_choice = false
	choice_a_btn.visible = false
	choice_b_btn.visible = false
	var mc = Global.player_name

	# Insert branch A steps, then the common steps after
	var branch_a: Array = [
		{"side": "left", "speaker": mc, "sprite": "mc_default", "text": "I'm doing good, thanks. How about you? You must be Kitika?"},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default", "text": "Yes that's me, welcome!"},
	]
	_insert_and_continue(branch_a, mc)

func _on_choice_b() -> void:
	waiting_for_choice = false
	choice_a_btn.visible = false
	choice_b_btn.visible = false
	var mc = Global.player_name

	var branch_b: Array = [
		{"side": "left", "speaker": mc, "sprite": "mc_nervous", "text": "No, that's not me, must be the wrong person. Weirdo."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm", "text": "Oh! Well... That's odd."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default", "text": "I don't think I care. You work for me now, ok?"},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk", "text": "No buts, you don't want to know what I'm capable of."},
		{"side": "left", "speaker": mc, "sprite": "mc_bashful", "text": "…"},
		{"side": "left", "speaker": mc, "sprite": "mc_nervous", "text": "…alright"},
	]
	_insert_and_continue(branch_b, mc)

func _insert_and_continue(branch: Array, mc: String) -> void:
	var common: Array = _common_steps(mc)
	# Replace the choice step and everything after with branch + common
	steps.resize(step)  # trim from current step onward
	steps.append_array(branch)
	steps.append_array(common)
	show_step()

func _common_steps(mc: String) -> Array:
	return [
		# --- Introduce coworkers ---
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "Let me introduce you to your coworkers."},

		# Billy appears
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "This is Billy, our pastry chef. His food is killer.",
		 "extra": "billy_default", "bob_extra": true},
		{"side": "right", "speaker": "Billy", "sprite": "billy_talking",
		 "swap_right": "billy_talking", "hide_extra": true,
		 "text": "So nice to finally meet you, " + mc + ". I must warn you my knives are quite sharp, be careful to not lose your tail."},
		{"side": "left", "speaker": mc, "sprite": "mc_bashful",
		 "text": "Uh okay, nice to meet you too…"},

		# Gato appears
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "swap_right": "kitika_default",
		 "text": "Right, whatever. Meet Gato. She is our cashier.",
		 "extra": "gato_default", "bob_extra": true},
		{"side": "right", "speaker": "Gato", "sprite": "gato_default",
		 "swap_right": "gato_default", "hide_extra": true,
		 "text": "Just don't be annoying, okay?"},
		{"side": "right", "speaker": "Gato", "sprite": "gato_annoyed",
		 "swap_right": "gato_annoyed",
		 "text": "I've got a jar of fleas and I'm not afraid to use them."},
		{"side": "left", "speaker": mc, "sprite": "mc_bashful",
		 "text": "Okay… whatever you say…"},

		# Back to just Kitika and MC
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "swap_right": "kitika_default", "hide_extra": true,
		 "text": "Right! Well, let's get to work now."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm",
		 "text": "I doubt I'll have to teach you much."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "I was very impressed by all the experience you had on your resume."},
		{"side": "left", "speaker": mc + " (thinking)", "sprite": "mc_bashful",
		 "text": "ACK IM SO DIDDLY DARN STUPDOODLES, I LIED.\n…I guess I'll just have to figure it out."},
		{"side": "left", "speaker": mc, "sprite": "mc_nervous",
		 "text": "Yeah...haha"},

		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "Well, you won't actually need most of your training yet. Our drinks are pretty simple."},
		{"side": "left", "speaker": mc, "sprite": "mc_default",
		 "text": "Ah, okay!"},
		{"side": "left", "speaker": mc + " (thinking)", "sprite": "mc_nervous",
		 "text": "thank the cat lords"},
	]

func show_step() -> void:
	if step >= steps.size():
		# Scene done — transition to next scene
		# get_tree().change_scene_to_file("res://scenes/next_scene.tscn")
		return

	var s = steps[step]

	# --- Handle choice step ---
	if s.get("choice", false):
		waiting_for_choice = true
		choice_a_btn.text = s["a_text"]
		choice_b_btn.text = s["b_text"]
		choice_a_btn.visible = true
		choice_b_btn.visible = true
		return

	# --- Background ---
	if s.has("bg"):
		outside.visible = (s["bg"] == "outside")
		inside.visible = (s["bg"] == "inside")

	# --- Characters ---
	if s.has("show_left"):
		character_left.visible = s["show_left"]

	# Left character sprite
	if s["side"] == "left":
		character_left.visible = true
		character_left.change_sprite(s["sprite"])

	# Right character sprite
	if s["side"] == "right":
		character_right.visible = true
		if s.has("swap_right"):
			character_right.change_sprite(s["swap_right"])
		else:
			character_right.change_sprite(s["sprite"])

	# Extra character (Billy/Gato appearing next to Kitika)
	if s.has("extra"):
		character_extra.visible = true
		character_extra.change_sprite(s["extra"])
	if s.get("hide_extra", false):
		character_extra.visible = false
	if s.get("bob_extra", false):
		_bob_character(character_extra)

	# --- Dialogue ---
	if s["side"] == "left":
		chatbox_left.visible = true
		chatbox_right.visible = false
		speaker_left.text = s["speaker"]
		ui.typewriter(dialogue_left, s["text"])
	else:
		chatbox_right.visible = true
		chatbox_left.visible = false
		speaker_right.text = s["speaker"]
		ui.typewriter(dialogue_right, s["text"])

func _on_dialogue_button_pressed() -> void:
	if waiting_for_choice:
		return
	if ui.is_typing():
		ui.typewriter_skip()
		return
	step += 1
	show_step()

func _bob_character(node: TextureRect) -> void:
	var tween = create_tween().set_loops(3)
	var origin_y = node.position.y
	tween.tween_property(node, "position:y", origin_y - 10, 0.15)
	tween.tween_property(node, "position:y", origin_y, 0.15)
