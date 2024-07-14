extends MarginContainer

@export var curse_texture_1: TextureRect
@export var curse_texture_2: TextureRect
@export var curse_texture_3: TextureRect

@export var lock_button_1: Button
@export var lock_button_2: Button
@export var lock_button_3: Button

@export var shuffle_button: Button

var price = 1

signal shuffle
signal lock_curse(index: int)
signal unlock_curse(index: int)


func _ready() -> void:
	shuffle_button.pressed.connect(shuffle_curses)
	lock_button_1.lock_curse.connect(on_lock_select)
	lock_button_2.lock_curse.connect(on_lock_select)
	lock_button_3.lock_curse.connect(on_lock_select)
	lock_button_1.unlock_curse.connect(on_unlock_select)
	lock_button_2.unlock_curse.connect(on_unlock_select)
	lock_button_3.unlock_curse.connect(on_unlock_select)


func refresh_curse_UI(icon_1: Texture2D, icon_2: Texture2D, icon_3: Texture2D) -> void:
	curse_texture_1.texture = icon_1
	curse_texture_2.texture = icon_2
	curse_texture_3.texture = icon_3


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
		
