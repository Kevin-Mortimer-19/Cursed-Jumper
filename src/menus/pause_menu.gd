extends CenterContainer

@export_group("Node References")
@export var button_continue: Button
@export var button_options: Button
@export var button_quit: Button



func _ready() -> void:
	if get_tree().current_scene != self:
		hide()
	
	_set_up_sfx(button_continue)
	_set_up_sfx(button_options)
	_set_up_sfx(button_quit)
	
	button_continue.pressed.connect(_on_continue_pressed)
	button_options.pressed.connect(_on_options_pressed)
	button_quit.pressed.connect(_on_quit_pressed)
	
	visibility_changed.connect(
		func():
			if visible:
				button_continue.grab_focus()
	)
	
	OptionsMenu.request_back.connect(_animate_options_exit)



func _set_up_sfx(button: Button) -> void:
	button.focus_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))
	button.mouse_entered.connect(SoundManager.play_ui_sound.bind(SoundManager.SOUND_BUTTON_HOVER))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		get_tree().paused = false


func _on_continue_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_options_pressed() -> void:
	_animate_options_enter()

func _on_quit_pressed() -> void:
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
	print("???")
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(OptionsMenu, "position:x", size.x, 0.2)
	
	tween.chain().tween_property(self, "position:x", 0, 0.3)
	tween.chain().tween_property(OptionsMenu, "visible", false, 0)
	
	tween.chain().tween_callback(button_options.grab_focus)















