extends Node



signal open_curse_shuffle_menu
signal change_coin_amount
signal refresh_curse_UI(curses: Array[int])

static var _coin_scene: PackedScene = preload("res://src/objects/coin.tscn")

@export var checkpoint: Area2D
@export var player: Player
@export var camera: Camera2D

var coin_amount: int = 2





func _ready() -> void:
	SoundManager.play_music(load("res://assets/music/spaced - rough.mp3"))
	
	_connect_signals()


func _connect_signals():
	checkpoint.checkpoint_entered.connect(player.heal)
	checkpoint.checkpoint_activated.connect(checkpoint_activated)
	
	player.curses_applied.connect(_curses_applied)
	EventBus.player_respawn_requested.connect(_on_player_respawn_requested)
	
	EventBus.coin_created.connect(_create_coin)
	EventBus.coin_picked_up.connect(_gain_coin)


func checkpoint_activated() -> void:
	open_curse_shuffle_menu.emit()


func _curses_applied(curses: Array[int]) -> void:
	refresh_curse_UI.emit(curses)


func shuffle_curse():
	player.shuffle_curse()


func lock_curse(index: int):
	player.lock_curse(index)


func unlock_curse(index: int):
	player.unlock_curse(index)


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
	change_coin_amount.emit()


func _spend_coin(amount: int) -> void:
	coin_amount -= amount
	change_coin_amount.emit()

func _on_player_respawn_requested() -> void:
	await ScreenTransition.animate_transition(true)
	
	player.heal()
	player.shotgun.sprite.play()
	player.sprite.play("default")
	player.global_position = checkpoint.global_position
	player.velocity = Vector2.ZERO
	camera.global_position = player.global_position
	
	await ScreenTransition.animate_transition(false)
	
	player.is_dead_locked = false






