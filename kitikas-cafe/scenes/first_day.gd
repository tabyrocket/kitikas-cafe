extends Control

@export var freezer_frame_duration: float = 1.0
@export var freezer_transition_length: float = 1.0

# References
@onready var outside: TextureRect = $Backgrounds/Outside
@onready var inside: TextureRect = $Backgrounds/Inside
@onready var inside_night: TextureRect = $Backgrounds/InsideNight
@onready var stairs: TextureRect = $Backgrounds/Stairs
@onready var ending_b: TextureRect = $Backgrounds/EndingB
@onready var syrup: TextureRect = $Syrup
@onready var dark_overlay: ColorRect = $Backgrounds/DarkOverlay
@onready var character_left: TextureRect = $CharacterLeft
@onready var character_right: TextureRect = $CharacterRight
@onready var character_extra: TextureRect = $CharacterExtra
@onready var stab_sound: AudioStreamPlayer = $StabSound


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
var waiting_for_anim: bool = false

func _ready() -> void:
	outside.visible = true
	inside.visible = false
	inside_night.visible = false
	stairs.visible = false
	ending_b.visible = false
	syrup.visible = false
	dark_overlay.visible = false
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

		# --- Choice 1 ---
		{"choice": true, "id": "greet",
		 "a_text": "I'm doing good, thanks. How about you? You must be Kitika?",
		 "b_text": "No, that's not me, must be the wrong person. Weirdo."},
	]

func _on_choice_a() -> void:
	waiting_for_choice = false
	choice_a_btn.visible = false
	choice_b_btn.visible = false
	var mc = Global.player_name
	var s = steps[step]
	var id = s.get("id", "")

	if id == "greet":
		var branch: Array = [
			{"side": "left", "speaker": mc, "sprite": "mc_default", "text": "I'm doing good, thanks. How about you? You must be Kitika?"},
			{"side": "right", "speaker": "Kitika", "sprite": "kitika_default", "text": "Yes that's me, welcome!"},
		]
		_insert_and_continue(branch, mc)
	elif id == "basement":
		# Outcome A — unimplemented, placeholder
		var branch: Array = [
			{"side": "left", "speaker": mc, "sprite": "mc_default", "text": "..."},
		]
		_insert_and_continue(branch, mc)

func _on_choice_b() -> void:
	waiting_for_choice = false
	choice_a_btn.visible = false
	choice_b_btn.visible = false
	var mc = Global.player_name
	var s = steps[step]
	var id = s.get("id", "")

	if id == "greet":
		var branch: Array = [
			{"side": "left", "speaker": mc, "sprite": "mc_bashful", "text": "No, that's not me, must be the wrong person. Weirdo."},
			{"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm", "text": "Oh! Well... That's odd."},
			{"side": "right", "speaker": "Kitika", "sprite": "kitika_default", "text": "I don't think I care. You work for me now, ok?"},
			{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk", "text": "No buts, you don't want to know what I'm capable of."},
			{"side": "left", "speaker": mc, "sprite": "mc_nervous", "text": "…"},
			{"side": "left", "speaker": mc, "sprite": "mc_bashful", "text": "…alright"},
		]
		_insert_and_continue(branch, mc)
	elif id == "basement":
		_ending_b(mc)

func _insert_and_continue(branch: Array, mc: String) -> void:
	var common: Array = _common_steps(mc)
	steps.resize(step)
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
		{"side": "left", "speaker": mc, "sprite": "mc_nervous",
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
		{"side": "left", "speaker": mc, "sprite": "mc_nervous",
		 "text": "Okay… whatever you say…"},

		# Back to just Kitika and MC
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "swap_right": "kitika_default", "hide_extra": true,
		 "text": "Right! Well, let's get to work now."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm",
		 "text": "I doubt I'll have to teach you much."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "I was very impressed by all the experience you had on your resume."},
		{"side": "left", "speaker": mc + " (thinking)", "sprite": "mc_nervous",
		 "text": "ACK IM SO DIDDLY DARN STUPDOODLES, I LIED.\n…I guess I'll just have to figure it out."},
		{"side": "left", "speaker": mc, "sprite": "mc_bashful",
		 "text": "Yeah...haha"},

		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "Well, you won't actually need most of your training yet. Our drinks are pretty simple."},
		{"side": "left", "speaker": mc, "sprite": "mc_default",
		 "text": "Ah, okay!"},
		{"side": "left", "speaker": mc + " (thinking)", "sprite": "mc_bashful",
		 "text": "thank the cat lords"},

		# --- Syrup revelation ---
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "I just mix milk with my super secret syrup."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk",
		 "show_syrup": true,
		 "text": "Everykitty goes CRAZY for it. It's *illegal* to make something so good."},
		{"side": "left", "speaker": mc, "sprite": "mc_default",
		 "show_left": true,
		 "text": "Cool, can I ask what the syrup is made of?"},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm",
		 "text": "Hmmm, I don't usually tell kitties like you."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk",
		 "text": "But since you work here, how about I show you at the end of your shift?"},
		{"side": "left", "speaker": mc, "sprite": "mc_default",
		 "text": "Okay!"},

		# --- Time skip: dark screen + day is over ---
		{"anim": "time_skip"},

		# --- Night ---
		{"bg": "inside_night", "side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "show_left": true,
		 "text": "You must be tired after your first shift."},
		{"side": "left", "speaker": mc, "sprite": "mc_default",
		 "text": "Yeah, I hope I'll get used to this."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "Don't worry,"},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk",
		 "text": "I'll make sure you rest forever...", "suspense": true},
		{"side": "left", "speaker": mc + " (thinking)", "sprite": "mc_bashful",
		 "text": "That's a weird thing to say..."},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "OKAY! My super awesome syrup making is downstairs in the basement, let's go!"},

		# --- Transition to stairs ---
		{"anim": "fade_to_stairs"},

		{"bg": "stairs", "side": "left", "speaker": mc, "sprite": "mc_nervous",
		 "show_left": true,
		 "text": "…"},
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_default",
		 "text": "Don't be scared, everything downstairs is perfectly normal and legal."},
		{"side": "left", "speaker": mc, "sprite": "mc_nervous",
		 "text": "*GULP*"},

		# --- Choice 2: follow or leave ---
		{"choice": true, "id": "basement",
		 "a_text": "Follow her",
		 "b_text": "Actually, I think I am going to go home."},
	]

# --- Ending B sequence (played via tweens, not steps) ---
func _ending_b(mc: String) -> void:
	waiting_for_anim = true
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false

	# Fade to black
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade = create_tween()
	fade.tween_property(dark_overlay, "modulate:a", 1.0, 1.0)
	await fade.finished

	stab_sound.play()

	# Switch to ending bg
	_hide_all_bgs()
	ending_b.visible = true

	# Fade back in
	var reveal = create_tween()
	reveal.tween_property(dark_overlay, "modulate:a", 0.0, 1.5)
	await reveal.finished
	dark_overlay.visible = false

	# Final dialogue
	waiting_for_anim = false
	steps.resize(step)
	steps.append(
		{"side": "right", "speaker": "Kitika",
		 "text": "The secret ingredient was innocent little kittens like you, my dear " + mc + ". :3 Why are you so surprised? You agreed to this after all."}
	)
	steps.append({"anim": "the_end"})
	show_step()

func show_step() -> void:
	if step >= steps.size():
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

	# --- Handle animation steps ---
	if s.has("anim"):
		_play_anim(s["anim"])
		return

	# --- Background ---
	if s.has("bg"):
		_set_bg(s["bg"])

	# --- Characters ---
	if ending_b.visible:
		character_left.visible = false
		character_right.visible = false
		character_extra.visible = false
	else:
		if s.has("show_left"):
			character_left.visible = s["show_left"]
		if s.has("show_right"):
			character_right.visible = s["show_right"]
	
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

	if s.get("show_syrup", false):
		syrup.visible = true

	# --- Dialogue ---
	if s["side"] == "left":
		chatbox_left.visible = true
		chatbox_right.visible = false
		speaker_left.text = s["speaker"]
		ui.typewriter(dialogue_left, s["text"])
		
		# Darken inactive side
		character_left.modulate = Color(1, 1, 1)
		character_right.modulate = Color(0.5, 0.5, 0.5)
		character_extra.modulate = Color(0.5, 0.5, 0.5)
	else:
		chatbox_right.visible = true
		chatbox_left.visible = false
		speaker_right.text = s["speaker"]
		ui.typewriter(dialogue_right, s["text"])
		
		# Darken inactive side
		character_left.modulate = Color(0.5, 0.5, 0.5)
		character_right.modulate = Color(1, 1, 1)
		character_extra.modulate = Color(1, 1, 1)

	# --- Suspense: slow down typewriter for dramatic lines ---
	if s.get("suspense", false):
		ui.TYPEWRITER_SPEED = 0.06
	else:
		ui.TYPEWRITER_SPEED = 0.02

func _on_dialogue_button_pressed() -> void:
	if waiting_for_choice or waiting_for_anim:
		return
	if ui.is_typing():
		ui.typewriter_skip()
		return
	step += 1
	show_step()

# --- Helper: set background ---
func _set_bg(bg_name: String) -> void:
	_hide_all_bgs()
	match bg_name:
		"outside": outside.visible = true
		"inside": inside.visible = true
		"inside_night": inside_night.visible = true
		"stairs": stairs.visible = true
		"ending_b": ending_b.visible = true

func _hide_all_bgs() -> void:
	outside.visible = false
	inside.visible = false
	inside_night.visible = false
	stairs.visible = false
	ending_b.visible = false

# --- Animation sequences ---
func _play_anim(anim_name: String) -> void:
	waiting_for_anim = true
	match anim_name:
		"time_skip":
			await _anim_time_skip()
		"fade_to_stairs":
			await _anim_fade_to_stairs()
		"the_end":
			await _anim_the_end()
	waiting_for_anim = false
	step += 1
	show_step()

func _anim_time_skip() -> void:
	# Hide chatboxes, characters, and syrup
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false
	syrup.visible = false

	# Fade to black
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade_in = create_tween()
	fade_in.tween_property(dark_overlay, "modulate:a", 1.0, 1.2)
	await fade_in.finished

	# Switch bg while black
	_hide_all_bgs()
	inside_night.visible = true

	# Hold on black (clock moment)
	await get_tree().create_timer(2.0).timeout

	# Fade out
	var fade_out = create_tween()
	fade_out.tween_property(dark_overlay, "modulate:a", 0.0, 1.2)
	await fade_out.finished
	dark_overlay.visible = false

func _anim_fade_to_stairs() -> void:
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false

	# Fade to black
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade_in = create_tween()
	fade_in.tween_property(dark_overlay, "modulate:a", 1.0, 0.8)
	await fade_in.finished

	# Switch bg while black
	_hide_all_bgs()
	stairs.visible = true

	await get_tree().create_timer(0.5).timeout

	# Fade back in
	var fade_out = create_tween()
	fade_out.tween_property(dark_overlay, "modulate:a", 0.0, 0.8)
	await fade_out.finished
	dark_overlay.visible = false

func _anim_the_end() -> void:
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_right.visible = false

	# Dramatic fade to black
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade = create_tween()
	fade.tween_property(dark_overlay, "modulate:a", 1.0, 2.0)
	await fade.finished

	# Hold for dramatic pause
	await get_tree().create_timer(3.0).timeout

	# Play the freezer cutscene at the very end
	await _play_freezer_cutscene()

	# TODO: Show "THE END" text or transition to credits/menu
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _play_freezer_cutscene() -> void:
	var cutscene_parent = Control.new()
	cutscene_parent.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Backgrounds.add_child(cutscene_parent)
	
	var dir = DirAccess.open("res://assets/freezer-cutscene")
	var final_files = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".import"):
				var actual_file = file_name.replace(".import", "")
				if not final_files.has(actual_file):
					final_files.append(actual_file)
			elif file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				if not final_files.has(file_name):
					final_files.append(file_name)
			file_name = dir.get_next()
			
		final_files.sort_custom(func(a, b):
			var num_a = a.get_basename().trim_prefix("freezer_").to_int()
			var num_b = b.get_basename().trim_prefix("freezer_").to_int()
			return num_a < num_b
		)
		
		for file in final_files:
			var tex = load("res://assets/freezer-cutscene/" + file)
			if tex:
				var tr = TextureRect.new()
				tr.texture = tex
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.set_anchors_preset(Control.PRESET_FULL_RECT)
				tr.modulate.a = 0.0
				cutscene_parent.add_child(tr)
				
				var tween = create_tween()
				tween.tween_property(tr, "modulate:a", 1.0, freezer_transition_length)
				await tween.finished
				
				await get_tree().create_timer(freezer_frame_duration).timeout

func _bob_character(node: TextureRect) -> void:
	var tween = create_tween().set_loops(3)
	var origin_y = node.position.y
	tween.tween_property(node, "position:y", origin_y - 10, 0.15)
	tween.tween_property(node, "position:y", origin_y, 0.15)
