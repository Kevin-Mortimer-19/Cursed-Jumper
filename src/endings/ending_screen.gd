extends Control

@export var exit_button: Button


func _ready() -> void:
	exit_button.pressed.connect(quit_game)


func quit_game() -> void:
	get_tree().quit()
