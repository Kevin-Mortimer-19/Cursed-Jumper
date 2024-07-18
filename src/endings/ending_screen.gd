extends Control

@export var exit_button: Button
#const TITLE_SCREEN: PackedScene = preload("res://src/menus/title_menu.tscn")

func _ready() -> void:
	exit_button.pressed.connect(quit_game)


func quit_game() -> void:
	get_tree().quit()
