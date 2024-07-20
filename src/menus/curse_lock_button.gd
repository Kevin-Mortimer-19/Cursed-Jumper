class_name LockButton extends Button

signal lock_curse(index: int)
signal unlock_curse(index: int)

var unlocked_text: String = "LOCK (%s)"
var locked_text: String = "UNLOCK"

@export var index: int

var locked: bool = false
var lock_price = 5



func _ready() -> void:
	unlocked_text = unlocked_text % lock_price
	text = unlocked_text
	mouse_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))
	focus_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))
	pressed.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_CONFIRM))


func _pressed():
	if locked:
		unlock_curse.emit(index)
		text = unlocked_text
		locked = false
	else:
		lock_curse.emit(index)
		text = locked_text
		locked = true
