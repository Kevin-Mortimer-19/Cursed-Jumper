extends Control



@export_group("Node References")
@export var background_sprite: AnimatedSprite2D
@export var button_play: Button
@export var button_options: Button
@export var button_quit: Button


const SCENE_GAME: PackedScene = preload("res://src/game.tscn")


func _ready() -> void:
	_connect_button_signals(button_play)
	button_play.pressed.connect(_on_play_button_pressed)
	_connect_button_signals(button_options)
	button_options.pressed.connect(_on_option_button_pressed)
	
	if OS.get_name() == "Web":
		button_quit.hide()
	else:
		_connect_button_signals(button_quit)
		button_quit.pressed.connect(_on_quit_button_pressed)
	
	OptionsMenu.request_back.connect(_animate_options_exit)
	
	# Play music, finally
	SoundManager.play_music(load("res://assets/music/jumper - rough.mp3"))

func _connect_button_signals(button: Button) -> void:
	button.mouse_entered.connect(_on_button_entered.bind(button, button.size))
	button.focus_entered.connect(_on_button_entered.bind(button, button.size))
	button.mouse_exited.connect(_on_button_exited.bind(button, button.size))
	button.focus_exited.connect(_on_button_exited.bind(button, button.size))

func _on_button_entered(button: Button, initial_size: Vector2) -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)
	var tween:= create_tween()
	tween.tween_property(button, "size:x", initial_size.x * 1.5, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()

func _on_button_exited(button: Button, initial_size: Vector2) -> void:
	var tween:= create_tween()
	tween.tween_property(button, "size:x", initial_size.x, 0.25)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()



func _on_play_button_pressed() -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_CONFIRM)
	# hide stuff
	button_play.hide()
	button_options.hide()
	button_quit.hide()
	await get_tree().create_timer(1.0).timeout
	# TODO: Do opening cutscene and transitions
	$CanvasLayer/Background/SubViewport/Background/AnimationPlayer.play("blastoff")
	await background_sprite.animation_finished
	
	await ScreenTransition.animate_transition(true)
	get_tree().change_scene_to_packed(SCENE_GAME)

func _on_option_button_pressed() -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_CONFIRM)
	_animate_options_enter()

func _on_quit_button_pressed() -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_CONFIRM)
	get_tree().quit()



func _animate_options_enter() -> void:
	OptionsMenu.position.x = size.x
	# Animate options
	var tween:= create_tween()
	tween.tween_property(self, "position:x", -size.x, 0.3)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.chain().tween_property(OptionsMenu, "visible", true, 0)
	tween.parallel().tween_property(OptionsMenu, "position:x", 0, 0.2)

func _animate_options_exit() -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(OptionsMenu, "position:x", size.x, 0.2)
	
	tween.chain().tween_property(self, "position:x", 0, 0.3)
	tween.chain().tween_property(OptionsMenu, "visible", false, 0)
	
	tween.chain().tween_callback(button_options.grab_focus)










