class_name LockButton extends Button

signal lock_curse(index: int)
signal unlock_curse(index: int)

var unlocked_text: String = "LOCK"
var locked_text: String = "UNLOCK"

@export var index: int

var locked: bool = false
var lock_price = 5



func _ready() -> void:
	mouse_entered.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_HOVER))
	focus_entered.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_HOVER))
	pressed.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_CONFIRM))


func _pressed():
	if locked:
		unlock_curse.emit(index)
		text = unlocked_text
		locked = false
	else:
		lock_curse.emit(index)
		text = locked_text
		locked = true
