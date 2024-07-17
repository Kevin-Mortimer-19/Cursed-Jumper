extends MarginContainer

@export var curse_icon_1: TextureRect
@export var curse_icon_2: TextureRect
@export var curse_icon_3: TextureRect

@export var lock_button_1: LockButton
@export var lock_button_2: LockButton
@export var lock_button_3: LockButton

@export var shuffle_button: Button

var price = 1

signal shuffle
signal lock_curse(index: int)
signal unlock_curse(index: int)


func _ready() -> void:
	_set_up_sfx(shuffle_button)
	shuffle_button.pressed.connect(shuffle_curses)
	
	lock_button_1.lock_curse.connect(on_lock_select)
	lock_button_2.lock_curse.connect(on_lock_select)
	lock_button_3.lock_curse.connect(on_lock_select)
	
	lock_button_1.unlock_curse.connect(on_unlock_select)
	lock_button_2.unlock_curse.connect(on_unlock_select)
	lock_button_3.unlock_curse.connect(on_unlock_select)


func refresh_curse_UI(icon_1: Array, icon_2: Array, icon_3: Array) -> void:
	curse_icon_1.texture = icon_1[0]
	curse_icon_1.tooltip_text = icon_1[1]
	curse_icon_2.texture = icon_2[0]
	curse_icon_2.tooltip_text = icon_2[1]
	curse_icon_3.texture = icon_3[0]
	curse_icon_3.tooltip_text = icon_3[1]


func on_lock_select(index: int) -> void:
	lock_curse.emit(index)


func on_unlock_select(index: int) -> void:
	unlock_curse.emit(index)


func shuffle_curses() -> void:
	shuffle.emit()


func price_check(amount: int) -> void:
	if amount < price:
		shuffle_button.disabled = true
		lock_button_1.disabled = true
		lock_button_2.disabled = true
		lock_button_3.disabled = true
	else:
		shuffle_button.disabled = false
		lock_button_1.disabled = false
		lock_button_2.disabled = false
		lock_button_3.disabled = false

func _set_up_sfx(button: Button) -> void:
	button.mouse_entered.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_HOVER))
	button.focus_entered.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_HOVER))
	
	button.pressed.connect(SoundManager.play_sound_nonpositional.bind(SoundManager.SOUND_BUTTON_CONFIRM))









