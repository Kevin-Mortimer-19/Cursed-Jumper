extends Node

signal screenshake_requested(strength: float, decay_rate: float)
signal hitfreeze_requested(timescale: float, duration: float)

signal player_respawn_requested

signal coin_created(global_position: Vector2)
signal coin_picked_up(amount: int)
signal coin_spent(amount: int)

signal transition_in
signal transition_out
signal transition_finished

var faster_enemy_curse_active: bool = false


func _ready() -> void:
	hitfreeze_requested.connect(_hitfreeze)

func _hitfreeze(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0



