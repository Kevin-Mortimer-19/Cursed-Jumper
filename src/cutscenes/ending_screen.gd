extends Control

@export var exit_button: Button

const CREDITS = preload("res://src/menus/credits/credits_menu.tscn")
const END_SONG = preload("res://assets/music/spaced ~ finale.mp3")


func _ready() -> void:
	SoundManager.play_music(END_SONG)
	exit_button.modulate.a = 0
	await ScreenTransition.animate_transition(false)
	exit_button.pressed.connect(move_to_credits)
	
	exit_button.mouse_entered.connect(_on_button_entered.bind(exit_button, exit_button.size))
	exit_button.focus_entered.connect(_on_button_entered.bind(exit_button, exit_button.size))
	exit_button.mouse_exited.connect(_on_button_exited.bind(exit_button, exit_button.size))
	exit_button.focus_exited.connect(_on_button_exited.bind(exit_button, exit_button.size))


func move_to_credits() -> void:
	await ScreenTransition.animate_transition(true)
	get_tree().change_scene_to_packed(CREDITS)


func _on_button_entered(_button: Button, _initial_size: Vector2) -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)


func _on_button_exited(_button: Button, _initial_size: Vector2) -> void:
	pass
