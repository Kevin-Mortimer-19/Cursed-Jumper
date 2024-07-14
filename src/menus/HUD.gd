extends MarginContainer

@export var curse_icon_1: TextureRect
@export var curse_icon_2: TextureRect
@export var curse_icon_3: TextureRect

func refresh_curse_UI(icon_1: Texture2D, icon_2: Texture2D, icon_3: Texture2D) -> void:
	curse_icon_1.texture = icon_1
	curse_icon_2.texture = icon_2
	curse_icon_3.texture = icon_3
