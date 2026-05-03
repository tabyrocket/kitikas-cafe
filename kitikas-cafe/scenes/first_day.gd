extends Control

@export var freezer_frame_duration: float = 1.0
@export var freezer_transition_length: float = 1.0

# References
@onready var outside: TextureRect = $Backgrounds/Outside
@onready var inside: TextureRect = $Backgrounds/Inside
@onready var inside_night: TextureRect = $Backgrounds/InsideNight
@onready var stairs: TextureRect = $Backgrounds/Stairs
@onready var basement: TextureRect = $Backgrounds/Basement
@onready var ending_b: TextureRect = $Backgrounds/EndingB
@onready var syrup: TextureRect = $Syrup
@onready var dark_overlay: ColorRect = $Backgrounds/DarkOverlay
@onready var clock: TextureRect = $Backgrounds/Clock
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
var achieved_ending: int = 0
var steps: Array = []
var waiting_for_choice: bool = false
var waiting_for_anim: bool = false
var waiting_for_input: bool = false

var last_words_container: Control
var last_words_input: LineEdit
var last_words_submit: Button

var creaky_stairs_player: AudioStreamPlayer

func _ready() -> void:
	outside.visible = true
	inside.visible = false
	inside_night.visible = false
	stairs.visible = false
	basement.visible = false
	ending_b.visible = false
	syrup.visible = false
	dark_overlay.visible = false
	clock.visible = false
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
	
	# Setup Last Words UI
	last_words_container = Control.new()
	last_words_container.visible = false
	last_words_container.set_anchors_preset(Control.PRESET_CENTER)
	last_words_container.size = Vector2(600, 150)
	last_words_container.position -= last_words_container.size / 2
	ui.get_node("Root").add_child(last_words_container)
	
	var font = choice_a_btn.get_theme_font("font")
	
	last_words_input = LineEdit.new()
	last_words_input.set_anchors_preset(Control.PRESET_TOP_WIDE)
	last_words_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	last_words_input.custom_minimum_size.y = 60
	last_words_input.placeholder_text = "Type your last words..."
	last_words_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	last_words_input.add_theme_font_override("font", font)
	last_words_input.add_theme_font_size_override("font_size", 24)
	last_words_container.add_child(last_words_input)
	
	last_words_submit = Button.new()
	last_words_submit.text = "Submit"
	last_words_submit.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	last_words_submit.size = Vector2(200, 50)
	last_words_submit.position = Vector2(200, 80)
	last_words_submit.add_theme_font_override("font", font)
	last_words_submit.add_theme_font_size_override("font_size", 20)
	# Use same styles as choice buttons if possible, or just defaults
	last_words_submit.pressed.connect(_on_last_words_submitted)
	last_words_container.add_child(last_words_submit)
	
	show_step()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		if chatbox_left.visible or chatbox_right.visible:
			_on_dialogue_button_pressed()

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
		var branch: Array = [
			{"anim": "fade_to_basement"},
			{"bg": "basement", "side": "right", "speaker": "Kitika", "sprite": "kitika_hmm", 
			 "text": "Just this way " + mc + ", don’t worry this is all normal :)"},
			{"choice": true, "id": "basement_follow",
			 "a_text": "Walk towards strange device",
			 "b_text": "RUN!"}
		]
		steps.resize(step)
		steps.append_array(branch)
		show_step()
		
		creaky_stairs_player = _play_sfx("res://assets/sound/creaky-stairs.mp3")
	elif id == "basement_follow":
		_ending_device(mc)

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
	elif id == "basement_follow":
		_ending_run(mc)

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
	achieved_ending = 1
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
	elif s.has("bg_texture"):
		_set_bg_texture(s["bg_texture"])

	# --- Characters ---
	var hide_chars = s.get("no_sprites", false)
	# Default EndingB behavior (no sprites unless it's the new ending system)
	if ending_b.visible and not s.has("bg_texture") and not s.has("anim"):
		hide_chars = true
		
	if hide_chars:
		character_left.visible = false
		character_right.visible = false
		character_extra.visible = false
	else:
		if s.has("show_left"):
			character_left.visible = s["show_left"]
		if s.has("show_right"):
			character_right.visible = s["show_right"]
	
		# Left character sprite
		if s.get("side") == "left":
			character_left.visible = true
			if s.has("sprite"):
				character_left.change_sprite(s["sprite"])
	
		# Right character sprite
		if s.get("side") == "right":
			character_right.visible = true
			if s.has("swap_right"):
				character_right.change_sprite(s["swap_right"])
			elif s.has("sprite"):
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
	if s.get("side") == "left":
		chatbox_left.visible = true
		chatbox_right.visible = false
		speaker_left.text = s.get("speaker", "")
		ui.typewriter(dialogue_left, s.get("text", ""))
		
		# Darken inactive side
		character_left.modulate = Color(1, 1, 1)
		character_right.modulate = Color(0.5, 0.5, 0.5)
		character_extra.modulate = Color(0.5, 0.5, 0.5)
	elif s.get("side") == "right":
		chatbox_right.visible = true
		chatbox_left.visible = false
		speaker_right.text = s.get("speaker", "")
		ui.typewriter(dialogue_right, s.get("text", ""))
		
		# Darken inactive side
		character_left.modulate = Color(0.5, 0.5, 0.5)
		character_right.modulate = Color(1, 1, 1)
		character_extra.modulate = Color(1, 1, 1)

	# --- Suspense: slow down typewriter for dramatic lines ---
	if s.get("suspense", false):
		ui.TYPEWRITER_SPEED = 0.06
	else:
		ui.TYPEWRITER_SPEED = 0.02

	# --- Last Words Input ---
	if s.get("last_words", false):
		waiting_for_input = true
		last_words_container.visible = true
		last_words_input.grab_focus()
	else:
		last_words_container.visible = false

func _on_dialogue_button_pressed() -> void:
	if waiting_for_choice or waiting_for_anim or waiting_for_input:
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
		"basement": basement.visible = true
		"ending_b": 
			ending_b.texture = load("res://assets/backgrounds/ending1_1.png")
			ending_b.visible = true

func _hide_all_bgs() -> void:
	outside.visible = false
	inside.visible = false
	inside_night.visible = false
	stairs.visible = false
	basement.visible = false
	ending_b.visible = false
	clock.visible = false
	syrup.visible = false

func _set_bg_texture(path: String) -> void:
	_hide_all_bgs()
	ending_b.texture = load(path)
	ending_b.visible = true

# --- Animation sequences ---
func _play_anim(anim_name: String) -> void:
	waiting_for_anim = true
	match anim_name:
		"time_skip":
			await _anim_time_skip()
		"fade_to_stairs":
			await _anim_fade_to_stairs()
		"fade_to_basement":
			await _anim_fade_to_basement()
		"ending3_start":
			await _anim_ending3_start()
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

	# Show Clock background
	clock.visible = true
	clock.modulate.a = 0.0
	var clock_fade_in = create_tween()
	clock_fade_in.tween_property(clock, "modulate:a", 1.0, 1.2)
	
	var bgm = get_node_or_null("/root/BGM")
	var orig_vol = -20.982
	if bgm:
		orig_vol = bgm.volume_db
		var vol_fade_out = create_tween()
		vol_fade_out.tween_property(bgm, "volume_db", -80.0, 1.2)
		
	await clock_fade_in.finished

	# Switch bg behind clock
	_hide_all_bgs()
	inside_night.visible = true
	clock.visible = true # Keep it visible since _hide_all_bgs hides it

	if bgm:
		bgm.stream = load("res://assets/sound/creepy-industrial-sounds-ambience.mp3")
		bgm.play()
		var vol_fade_in = create_tween()
		vol_fade_in.tween_property(bgm, "volume_db", orig_vol, 1.2)

	# Hold on clock
	await get_tree().create_timer(2.0).timeout

	# Fade out clock
	var clock_fade_out = create_tween()
	clock_fade_out.tween_property(clock, "modulate:a", 0.0, 1.2)
	await clock_fade_out.finished
	clock.visible = false

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

func _anim_fade_to_basement() -> void:
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
	basement.visible = true
	
	if creaky_stairs_player:
		creaky_stairs_player.stop()
		creaky_stairs_player.queue_free()
		creaky_stairs_player = null

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

	# Ensure dark overlay is on top of any dynamically added cutscene layers
	$Backgrounds.move_child(dark_overlay, -1)

	var melonrip_player = _play_sfx("res://assets/sound/melonrip.mp3")

	# Dramatic fade to black
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade = create_tween()
	fade.tween_property(dark_overlay, "modulate:a", 1.0, 2.0)
	await fade.finished

	# Hold for dramatic pause
	await get_tree().create_timer(3.0).timeout

	# Clear any previous cutscene layers before starting the final one
	for child in $Backgrounds.get_children():
		if child.name == "CutsceneParent":
			child.queue_free()

	# Play the freezer cutscene at the very end
	await _play_freezer_cutscene(melonrip_player)

	await _show_ending_screen()

func _anim_ending3_start() -> void:
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false
	
	# Fade to black before ending3_1.png
	dark_overlay.visible = true
	dark_overlay.modulate.a = 0.0
	var fade_out_screen = create_tween()
	fade_out_screen.tween_property(dark_overlay, "modulate:a", 1.0, 0.5)
	await fade_out_screen.finished
	
	# Show ending3_1
	_set_bg_texture("res://assets/backgrounds/ending3_1.png")
	
	# Fade back in to reveal ending3_1
	var fade_in_screen = create_tween()
	fade_in_screen.tween_property(dark_overlay, "modulate:a", 0.0, 0.5)
	await fade_in_screen.finished
	dark_overlay.visible = false
	
	await get_tree().create_timer(1.0).timeout
	
	# Fade to ending3_2
	var fade_tr = TextureRect.new()
	fade_tr.texture = load("res://assets/backgrounds/ending3_2.png")
	fade_tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade_tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_tr.modulate.a = 0.0
	$Backgrounds.add_child(fade_tr)
	
	var tween = create_tween()
	tween.tween_property(fade_tr, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# Now set the main ending_b to 3_2 and remove the temp one
	ending_b.texture = fade_tr.texture
	fade_tr.queue_free()

func _ending_device(mc: String) -> void:
	achieved_ending = 3
	waiting_for_anim = true
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false
	
	steps.resize(step)
	steps.append({"anim": "ending3_start"})
	steps.append({
		"bg_texture": "res://assets/backgrounds/ending3_2.png",
		"side": "right", "speaker": "Kitika", "sprite": "kitika_hmm",
		"text": "Well, well, well, I’m really sorry it had to end this way. NOT. Silly " + mc + ", you agreed to this…"
	})
	steps.append({
		"bg_texture": "res://assets/backgrounds/ending3_3.png",
		"no_sprites": true,
		"side": "right", "speaker": "Kitika",
		"text": "The secret ingredient was innocent little kittens like you, my dear " + mc + "."
	})
	steps.append({
		"bg_texture": "res://assets/backgrounds/ending3_4.png",
		"last_words": true,
		"side": "right", "speaker": "Kitika",
		"text": "Any last words?"
	})
	steps.append({
		"bg_texture": "res://assets/backgrounds/ending3_5.png",
		"no_sprites": true,
		"side": "right", "speaker": "Kitika",
		"text": "Okay, I don’t really care, you feline. I think I’ll start with your tail, it’s the ingredient for our most popular drink; strawkitty matcha latte."
	})
	steps.append({"anim": "the_end"})
	
	show_step()

func _on_last_words_submitted() -> void:
	waiting_for_input = false
	last_words_container.visible = false
	step += 1
	show_step()

func _ending_run(mc: String) -> void:
	achieved_ending = 2
	waiting_for_anim = true
	chatbox_left.visible = false
	chatbox_right.visible = false
	character_left.visible = false
	character_right.visible = false
	
	# Play ending2 cutscene
	await _play_ending2_cutscene()
	
	# Final dialogue before the very end
	waiting_for_anim = false
	steps.resize(step)
	steps.append(
		{"side": "right", "speaker": "Kitika", "sprite": "kitika_smirk",
		 "text": "The secret ingredient was innocent little kittens like you, my dear " + mc + ". :3 Why are you so surprised? You agreed to this after all."}
	)
	steps.append({"anim": "the_end"})
	show_step()

func _play_ending2_cutscene() -> void:
	var cutscene_parent = Control.new()
	cutscene_parent.name = "CutsceneParent"
	cutscene_parent.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Backgrounds.add_child(cutscene_parent)
	
	var images = [
		"res://assets/backgrounds/ending2_1.png",
		"res://assets/backgrounds/ending2_2.png",
		"res://assets/backgrounds/ending2_3.png",
		"res://assets/backgrounds/ending2_4.png"
	]
	
	var running_player: AudioStreamPlayer
	
	for path in images:
		if path == "res://assets/backgrounds/ending2_1.png":
			running_player = _play_sfx("res://assets/sound/running.mp3")
		elif path == "res://assets/backgrounds/ending2_3.png":
			if running_player:
				running_player.stop()
				running_player.queue_free()
			_play_sfx("res://assets/sound/knifestab.mp3")
		elif path == "res://assets/backgrounds/ending2_4.png":
			_play_sfx("res://assets/sound/thud.mp3")
			
		var tex = load(path)
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

func _play_freezer_cutscene(melonrip_player: AudioStreamPlayer = null) -> void:
	var cutscene_parent = Control.new()
	cutscene_parent.name = "CutsceneParent"
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
			if file == "freezer_2.png" and melonrip_player:
				melonrip_player.stop()
				melonrip_player.queue_free()
				melonrip_player = null
			elif file == "freezer_4.png":
				_play_sfx("res://assets/sound/freezer-open.mp3")
			elif file == "freezer_8.png":
				_play_sfx("res://assets/sound/jumpscare.mp3")
			elif file == "freezer_9.png":
				_play_sfx("res://assets/sound/rustle.mp3")
			elif file == "freezer_13.png":
				_play_sfx("res://assets/sound/freezer-close.mp3")
				
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

	if melonrip_player:
		melonrip_player.stop()
		melonrip_player.queue_free()

func _play_sfx(path: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	return player

func _bob_character(node: TextureRect) -> void:
	var tween = create_tween().set_loops(3)
	var origin_y = node.position.y
	tween.tween_property(node, "position:y", origin_y - 10, 0.15)
	tween.tween_property(node, "position:y", origin_y, 0.15)

func _show_ending_screen() -> void:
	var ending_num = achieved_ending
	if ending_num == 0:
		ending_num = 1 # Fallback
	
	var drink_name = ""
	var drink_texture_path = ""
	if ending_num == 1:
		drink_name = "MEOWCHA"
		drink_texture_path = "res://assets/images/meowcha.png"
	elif ending_num == 2:
		drink_name = "STRAWBERRY MEOWSHAKE"
		drink_texture_path = "res://assets/images/strawberrymeowshake.png"
	elif ending_num == 3:
		drink_name = "STRAWKITTY MATCHA LATTE"
		drink_texture_path = "res://assets/images/strawkittymatchalatte.png"
	
	var ending_ui = Control.new()
	ending_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_ui.z_index = 100
	ui.get_node("Root").add_child(ending_ui)
	
	var bg = ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_ui.add_child(bg)
	
	var content = Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_ui.add_child(content)
	
	var font = choice_a_btn.get_theme_font("font")
	
	var title = Label.new()
	title.text = "ENDING " + str(ending_num) + "/3"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 64)
	title.position.y = 100
	content.add_child(title)
	
	var drink_img = TextureRect.new()
	drink_img.texture = load(drink_texture_path)
	drink_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drink_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	drink_img.set_anchors_preset(Control.PRESET_CENTER)
	drink_img.custom_minimum_size = Vector2(400, 400)
	drink_img.position = -drink_img.custom_minimum_size / 2
	content.add_child(drink_img)
	
	var drink_label = Label.new()
	drink_label.text = drink_name
	drink_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	drink_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drink_label.add_theme_font_override("font", font)
	drink_label.add_theme_font_size_override("font_size", 48)
	drink_label.position.y = -150
	content.add_child(drink_label)
	
	ending_ui.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(ending_ui, "modulate:a", 1.0, 2.0)
	
	_play_sfx("res://assets/sound/sparkle.mp3")
	
	await tween.finished
	
	await get_tree().create_timer(4.0).timeout
	
	var tween2 = create_tween()
	tween2.tween_property(content, "modulate:a", 0.0, 2.0)
	await tween2.finished
	
	_play_credits(ending_ui)

func _play_credits(parent: Control) -> void:
	var video = VideoStreamPlayer.new()
	video.stream = load("res://assets/credits.ogv")
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	video.expand = true
	video.z_index = 101
	parent.add_child(video)
	video.play()
	
	video.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
