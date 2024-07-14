extends MarginContainer

@export var curse_texture_1: TextureRect
@export var curse_texture_2: TextureRect
@export var curse_texture_3: TextureRect

@export var shuffle_button: Button

signal shuffle

func _ready() -> void:
	shuffle_button.pressed.connect(shuffle_curses)

func refresh_curse_UI(icon_1: Texture2D, icon_2: Texture2D, icon_3: Texture2D) -> void:
	curse_texture_1.texture = icon_1
	curse_texture_2.texture = icon_2
	curse_texture_3.texture = icon_3


func shuffle_curses():
	shuffle.emit()
