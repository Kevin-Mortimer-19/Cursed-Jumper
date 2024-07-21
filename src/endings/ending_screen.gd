extends Control

@export var exit_button: Button

const CREDITS = preload("res://src/menus/credits/credits_menu.tscn")


func _ready() -> void:
	exit_button.pressed.connect(move_to_credits)


func move_to_credits() -> void:
	get_tree().change_scene_to_packed(CREDITS)
