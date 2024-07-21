extends MarginContainer


@export var button_quit: Button

func _ready() -> void:
	button_quit.pressed.connect(_on_quit_button_pressed)
	button_quit.mouse_entered.connect(_on_button_entered.bind(button_quit, button_quit.size))
	button_quit.focus_entered.connect(_on_button_entered.bind(button_quit, button_quit.size))
	button_quit.mouse_exited.connect(_on_button_exited.bind(button_quit, button_quit.size))
	button_quit.focus_exited.connect(_on_button_exited.bind(button_quit, button_quit.size))
	
	for child in get_tree().get_nodes_in_group("credit_slots"):
		if child is CreditSlot:
			(child as CreditSlot).meta_clicked.connect(_on_label_meta_clicked)

func _on_button_entered(_button: Button, _initial_size: Vector2) -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)
	#var tween:= create_tween()
	#tween.tween_property(button, "size:x", initial_size.x * 1.5, 0.2)
	#tween.set_ease(Tween.EASE_OUT)
	#tween.play()

func _on_button_exited(_button: Button, _initial_size: Vector2) -> void:
	#var tween:= create_tween()
	#tween.tween_property(button, "size:x", initial_size.x, 0.25)
	#tween.set_ease(Tween.EASE_OUT)
	#tween.play()
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_label_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))

