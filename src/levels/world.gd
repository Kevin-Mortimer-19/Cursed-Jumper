extends Node

signal open_curse_shuffle_menu

@export var checkpoint: Area2D
@export var player: CharacterBody2D

var coin_amount: int = 0



static var _coin_scene: PackedScene = preload("res://src/objects/coin.tscn")


func _ready() -> void:
	_connect_signals()

func _connect_signals():
	checkpoint.checkpoint_entered.connect(player.heal)
	checkpoint.checkpoint_activated.connect(signal_emitter.bind(open_curse_shuffle_menu))
	
	EventBus.coin_created.connect(_create_coin)
	EventBus.coin_picked_up.connect(_gain_coin)

func signal_emitter(s: Signal) -> void:
	s.emit()



func _create_coin(global_pos: Vector2) -> void:
	var rng:= RandomNumberGenerator.new()
	rng.randomize()
	
	var coin: Coin = _coin_scene.instantiate()
	coin.is_falling = true
	coin.velocity = Vector2.UP.rotated(rng.randf() * deg_to_rad(15))
	coin.global_position = global_pos
	call_deferred("add_child",coin)

func _gain_coin(amount: int) -> void:
	coin_amount += amount
	print(coin_amount)
