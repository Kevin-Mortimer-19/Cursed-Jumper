extends Node2D

const BUS_SFX = "SFX"
const BUS_MUSIC = "Music"
const BUS_UI = "UI"

const SOUND_BUTTON_HOVER:= preload("res://assets/sounds/ui_blips/glass_005.ogg")
const SOUND_BUTTON_CONFIRM:= preload("res://assets/sounds/ui_blips/drop_003.ogg")
const SOUND_DOWN:= preload("res://assets/sounds/ui_blips/switch4.ogg")
const SOUND_UP:= preload("res://assets/sounds/ui_blips/switch5.ogg")


var SFX_BUS_INDEX: int
var MUSIC_BUS_INDEX: int
var UI_BUS_INDEX: int

var current_sfx_volume: float = 0.5 : 
	set(val):
		current_sfx_volume = clampf(val, 0.0, 1.0)
		set_sfx_volume(current_sfx_volume)
var current_music_volume: float = 0.5 : 
	set(val):
		current_music_volume = clampf(val, 0.0, 1.0)
		set_music_volume(current_music_volume)

var music_player: AudioStreamPlayer

func _ready() -> void:
	SFX_BUS_INDEX = AudioServer.get_bus_index(BUS_SFX)
	MUSIC_BUS_INDEX = AudioServer.get_bus_index(BUS_MUSIC)



func set_sfx_volume(level: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_INDEX, linear_to_db(level))

func set_music_volume(level: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_INDEX, linear_to_db(level))

func play_ui_sound(stream: AudioStream) -> void:
	var player = create_generic_player(stream)
	player.bus = BUS_UI
	add_child(player)
	player.play()

func play_sound_nonpositional(stream: AudioStream) -> void:
	var player = create_generic_player(stream)
	player.bus = BUS_SFX
	add_child(player)
	player.play()

func play_sound_from_position(stream: AudioStream, position_global: Vector2) -> void:
	var player = AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = BUS_SFX
	add_child(player)
	player.global_position = position_global
	player.play()

func create_generic_player(stream: AudioStream) -> AudioStreamPlayer:
	var player:= AudioStreamPlayer.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	return player



func play_music(stream: AudioStream) -> void:
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.bus = BUS_MUSIC
		add_child(music_player)
	
	music_player.stream = stream
	music_player.play()








