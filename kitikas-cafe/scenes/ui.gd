extends CanvasLayer

@onready var pause_menu: ColorRect = $Root/PauseMenu
@onready var chatbox_left: TextureRect = $Root/ChatboxLeft
@onready var babble: AudioStreamPlayer = $Babble

# Typewriter state
var _tw_target: RichTextLabel = null
var _tw_full_text: String = ""
var _tw_index: int = 0
var _tw_timer: Timer = null
var _tw_on_done: Callable = Callable()

const TYPEWRITER_SPEED: float = 0.02  # seconds per character

func _ready() -> void:
	chatbox_left.visible = false
	pause_menu.visible = false

	# Create the typewriter timer
	_tw_timer = Timer.new()
	_tw_timer.one_shot = true
	_tw_timer.timeout.connect(_on_typewriter_tick)
	add_child(_tw_timer)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = not pause_menu.visible


func _on_pause_button_pressed() -> void:
	pause_menu.visible = not pause_menu.visible


## Starts a typewriter effect on [label], revealing [full_text] character by character.
## Optionally calls [on_done] when typing completes.
## Clicking while typing will skip to the end instantly.
func typewriter(label: RichTextLabel, full_text: String, on_done: Callable = Callable()) -> void:
	babble.play()
	
	# Cancel any ongoing typewriter
	if _tw_timer.time_left > 0:
		_tw_timer.stop()

	_tw_target = label
	_tw_full_text = full_text
	_tw_index = 0
	_tw_on_done = on_done

	_tw_target.text = ""
	_tw_timer.start(TYPEWRITER_SPEED)


## Call this (e.g. on a mouse click) to instantly skip to the end of the current typewrite.
func typewriter_skip() -> void:
	if _tw_target == null or _tw_full_text == "":
		return
	_tw_timer.stop()
	_tw_target.text = _tw_full_text
	_tw_target = null
	_tw_full_text = ""
	_tw_index = 0
	if _tw_on_done.is_valid():
		_tw_on_done.call()
	_tw_on_done = Callable()


## Returns true while the typewriter is still revealing text.
func is_typing() -> bool:
	return _tw_target != null and _tw_index < _tw_full_text.length()


func _on_typewriter_tick() -> void:
	if _tw_target == null:
		return
	_tw_index += 1
	_tw_target.text = _tw_full_text.left(_tw_index)
	if _tw_index < _tw_full_text.length():
		_tw_timer.start(TYPEWRITER_SPEED)
	else:
		# Typing done
		babble.stop()
		_tw_target = null
		_tw_full_text = ""
		_tw_index = 0
		if _tw_on_done.is_valid():
			_tw_on_done.call()
		_tw_on_done = Callable()
