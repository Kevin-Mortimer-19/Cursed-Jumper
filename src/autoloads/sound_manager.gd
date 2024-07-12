extends Node2D

const BUS_SFX = "SFX"
const BUS_MUSIC = "Music"
const BUS_UI = "UI"

var SFX_BUS_INDEX: int
var MUSIC_BUS_INDEX: int
var UI_BUS_INDEX: int


func _ready() -> void:
	SFX_BUS_INDEX = AudioServer.get_bus_index(BUS_SFX)
	MUSIC_BUS_INDEX = AudioServer.get_bus_index(BUS_MUSIC)



func set_sfx_volume(level: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_INDEX, linear_to_db(level))

func set_music_volume(level: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_INDEX, linear_to_db(level))

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










