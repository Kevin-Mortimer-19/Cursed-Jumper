extends MarginContainer

@export var sound_shuffle: AudioStream
@export var sound_open: AudioStream
@export var sound_close: AudioStream

@export_group("Node References")
@export var coin_coint: Button

@export var curse_icon_1: TextureRect
@export var curse_icon_2: TextureRect

@export var lock_button_1: LockButton
@export var lock_button_2: LockButton

@export var shuffle_button: Button

var price = 5

signal shuffle
signal lock_curse(index: int)
signal unlock_curse(index: int)


func _ready() -> void:
	_set_up_sfx(shuffle_button)
	visibility_changed.connect(_on_visibility_changed)
	shuffle_button.pressed.connect(shuffle_curses)
	
	lock_button_1.lock_curse.connect(on_lock_select)
	lock_button_2.lock_curse.connect(on_lock_select)
	
	lock_button_1.unlock_curse.connect(on_unlock_select)
	lock_button_2.unlock_curse.connect(on_unlock_select)


func animate_enter() -> void:
	position.y = size.y
	
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "visible", true, 0)
	tween.chain().tween_property(self, "position:y", 0, 0.5)
	
	tween.play()
	await tween.finished


func animate_exit() -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position:y", size.y, 0.2)
	tween.chain().tween_property(self, "visible", false, 0)
	
	tween.play()
	await tween.finished


func refresh_curse_UI(icon_1: Array, icon_2: Array) -> void:
	curse_icon_1.texture = icon_1[0]
	curse_icon_1.tooltip_text = icon_1[1]
	curse_icon_2.texture = icon_2[0]
	curse_icon_2.tooltip_text = icon_2[1]


func on_lock_select(index: int) -> void:
	lock_curse.emit(index)


func on_unlock_select(index: int) -> void:
	unlock_curse.emit(index)


func shuffle_curses() -> void:
	SoundManager.play_sound_nonpositional(sound_shuffle)
	shuffle.emit()


func price_check(amount: int) -> void:
	coin_coint.text = str(amount)
	
	if amount < price:
		shuffle_button.disabled = true
		lock_button_1.disabled = true
		lock_button_2.disabled = true
	else:
		shuffle_button.disabled = false
		lock_button_1.disabled = false
		lock_button_2.disabled = false


func _set_up_sfx(button: Button) -> void:
	button.mouse_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))
	button.focus_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))
	
	button.pressed.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_CONFIRM))


func _on_visibility_changed() -> void:
	SoundManager.play_sound_nonpositional(sound_open if visible else sound_close)

