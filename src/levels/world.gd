extends Node

@export var checkpoint: Area2D
@export var player: CharacterBody2D

signal open_curse_shuffle_menu

func _ready() -> void:
	_connect_signals()

func _connect_signals():
	checkpoint.checkpoint_entered.connect(player.heal)
	checkpoint.checkpoint_activated.connect(signal_emitter.bind(open_curse_shuffle_menu))

func signal_emitter(s: Signal) -> void:
	s.emit()
