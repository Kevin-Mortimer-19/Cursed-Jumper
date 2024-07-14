extends Node

@export var checkpoint: Area2D
@export var player: CharacterBody2D

signal open_curse_shuffle_menu

signal refresh_curse_UI(curses: Array[int])

func _ready() -> void:
	_connect_signals()

func _connect_signals():
	checkpoint.checkpoint_entered.connect(player.heal)
	checkpoint.checkpoint_activated.connect(checkpoint_activated)
	player.curses_applied.connect(_curses_applied)

func checkpoint_activated() -> void:
	open_curse_shuffle_menu.emit()

func _curses_applied(curses: Array[int]) -> void:
	refresh_curse_UI.emit(curses)

func shuffle_curse():
	player.shuffle_curse()
