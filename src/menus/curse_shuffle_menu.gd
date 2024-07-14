extends MarginContainer

@export var curse_texture_1: TextureRect
@export var curse_texture_2: TextureRect
@export var curse_texture_3: TextureRect

@export var lock_button_1: Button
@export var lock_button_2: Button
@export var lock_button_3: Button

@export var shuffle_button: Button

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

func on_lock_select(index: int):
	lock_curse.emit(index)

func on_unlock_select(index: int):
	unlock_curse.emit(index)

func shuffle_curses():
	shuffle.emit()
