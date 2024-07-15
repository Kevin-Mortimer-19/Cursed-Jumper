extends Node

signal coin_created(global_position: Vector2)
signal coin_picked_up(amount: int)
signal coin_spent(amount: int)

var faster_enemy_curse_active: bool = false


