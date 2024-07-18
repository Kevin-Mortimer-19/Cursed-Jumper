extends CenterContainer

signal request_back

@export_group("Node References")
@export var button_return: Button
@export_subgroup("Music")
@export var option_music: Button
@export var music_buttons_container: HBoxContainer
@export var button_music_down: Button
@export var button_music_up: Button
@export var label_music_volume: Label

@export_subgroup("SFX")
@export var option_sfx: Button
@export var sfx_buttons_container: HBoxContainer
@export var button_sfx_down: Button
@export var button_sfx_up: Button
@export var label_sfx_volume: Label

@export_subgroup("Fullscreen")
@export var option_fullscreen: Button
@export var label_fullscreen: Label

var _button_deselect_color:= Color("8e7377")

func _ready() -> void:
	if not get_tree().current_scene == self:
		hide()
	
	_set_up_music()
	_set_up_sfx()
	_set_up_fullscreen()
	
	button_return.focus_entered.connect(_on_return_selected)
	button_return.mouse_entered.connect(_on_return_selected)
	button_return.pressed.connect(_on_return_pressed)
	
	
	visibility_changed.connect(
		func():
			option_music.grab_focus()
	)
	
	label_music_volume.text = "%s%%" % (SoundManager.current_music_volume * 100)
	label_sfx_volume.text = "%s%%" % (SoundManager.current_sfx_volume * 100)


func _on_option_selected(button: Button, container: HBoxContainer) -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)
	
	button.set("theme_override_colors/font_color", Color.WHITE)
	for control in container.get_children():
		control.set("theme_override_colors/font_color", Color.WHITE)

func _on_option_deselected(button: Button, container: HBoxContainer) -> void:
	button.set("theme_override_colors/font_color", _button_deselect_color)
	for control in container.get_children():
		control.set("theme_override_colors/font_color", _button_deselect_color)

func _on_fullscreen_selected(button: Button, label: Label) -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)
	label.set("theme_override_colors/font_color", Color.WHITE)

func _on_fullscreen_deselected(button: Button, label: Label) -> void:
	label.set("theme_override_colors/font_color", button.get("theme_override_colors/font_color"))

func _set_up_music() -> void:
	option_music.focus_entered.connect(_on_option_selected.bind(option_music, music_buttons_container))
	option_music.mouse_entered.connect(_on_option_selected.bind(option_music, music_buttons_container))
	option_music.focus_exited.connect(_on_option_deselected.bind(option_music, music_buttons_container))
	option_music.mouse_exited.connect(_on_option_deselected.bind(option_music, music_buttons_container))
	
	music_buttons_container.mouse_entered.connect(_on_option_selected.bind(option_music, music_buttons_container))
	music_buttons_container.mouse_exited.connect(_on_option_deselected.bind(option_music, music_buttons_container))
	
	button_music_down.pressed.connect(_adjust_music_volume.bind(false))
	button_music_up.pressed.connect(_adjust_music_volume.bind(true))


func _set_up_sfx() -> void:
	option_sfx.focus_entered.connect(_on_option_selected.bind(option_sfx, sfx_buttons_container))
	option_sfx.mouse_entered.connect(_on_option_selected.bind(option_sfx, sfx_buttons_container))
	option_sfx.focus_exited.connect(_on_option_deselected.bind(option_sfx, sfx_buttons_container))
	option_sfx.mouse_exited.connect(_on_option_deselected.bind(option_sfx, sfx_buttons_container))
	
	sfx_buttons_container.mouse_entered.connect(_on_option_selected.bind(option_sfx, sfx_buttons_container))
	sfx_buttons_container.mouse_exited.connect(_on_option_deselected.bind(option_sfx, sfx_buttons_container))
	
	button_sfx_down.pressed.connect(_adjust_sfx_volume.bind(false))
	button_sfx_up.pressed.connect(_adjust_sfx_volume.bind(true))


func _set_up_fullscreen() -> void:
	option_fullscreen.focus_entered.connect(_on_fullscreen_selected.bind(option_fullscreen, label_fullscreen))
	option_fullscreen.mouse_entered.connect(_on_fullscreen_selected.bind(option_fullscreen, label_fullscreen))
	option_fullscreen.focus_exited.connect(_on_fullscreen_deselected.bind(option_fullscreen, label_fullscreen))
	option_fullscreen.mouse_exited.connect(_on_fullscreen_deselected.bind(option_fullscreen, label_fullscreen))


func _input(event: InputEvent) -> void:
	if option_music.has_focus():
		if event.is_action_pressed("ui_left"):
			_adjust_music_volume(false)
		elif event.is_action_pressed("ui_right"):
			_adjust_music_volume(true)
		elif event.is_action_pressed("ui_cancel"):
			#option_music.release_focus()
			request_back.emit()
	
	elif option_sfx.has_focus():
		if event.is_action_pressed("ui_left"):
			_adjust_sfx_volume(false)
		elif event.is_action_pressed("ui_right"):
			_adjust_sfx_volume(true)
		elif event.is_action_pressed("ui_cancel"):
			#option_sfx.release_focus()
			request_back.emit()
	
	elif option_fullscreen.has_focus():
		if event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_left") \
			or event.is_action_pressed("ui_right"):
			_toggle_fullscreen()
		elif event.is_action_pressed("ui_cancel"):
			#option_fullscreen.release_focus()
			request_back.emit()
	
	else:
		if event.is_action_pressed("ui_cancel") and visible:
			request_back.emit()


func _adjust_music_volume(increase: bool) -> void:
	if increase:
		SoundManager.current_music_volume += 0.1
		SoundManager.play_ui_sound(SoundManager.SOUND_UP)
	else:
		SoundManager.current_music_volume -= 0.1
		SoundManager.play_ui_sound(SoundManager.SOUND_DOWN)
	label_music_volume.text = "%s%%" % (SoundManager.current_music_volume * 100)


func _adjust_sfx_volume(increase: bool) -> void:
	if increase:
		SoundManager.current_sfx_volume += 0.1
		SoundManager.play_ui_sound(SoundManager.SOUND_UP)
	else:
		SoundManager.current_sfx_volume -= 0.1
		SoundManager.play_ui_sound(SoundManager.SOUND_DOWN)
	label_sfx_volume.text = "%s%%" % (SoundManager.current_sfx_volume * 100)



func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		label_fullscreen.text = "<ON>"
		SoundManager.play_ui_sound(SoundManager.SOUND_UP)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		label_fullscreen.text = "<OFF>"
		SoundManager.play_ui_sound(SoundManager.SOUND_DOWN)


func _on_return_selected() -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_HOVER)


func _on_return_pressed() -> void:
	SoundManager.play_ui_sound(SoundManager.SOUND_BUTTON_CONFIRM)
	request_back.emit()






