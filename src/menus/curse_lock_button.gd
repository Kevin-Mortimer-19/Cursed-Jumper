extends Button

var unlocked_text: String = "Lock"
var locked_text: String = "Unlock"

@export var index: int

var locked: bool = false

var lock_price = 5


signal lock_curse(index: int)
signal unlock_curse(index: int)


func _pressed():
	if locked:
		unlock_curse.emit(index)
		text = unlocked_text
		locked = false
	else:
		lock_curse.emit(index)
		text = locked_text
		locked = true
