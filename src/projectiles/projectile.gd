class_name Projectile extends CharacterBody2D

@export var damage: int
@export var move_speed: float
@export var lifetime: float

@export_group("Sound")
@export var enemy_impact: AudioStream
@export var environment_impact: AudioStream

@export_group("Node References")
@export var hitbox: Area2D


var _lifetime_remaining: float = 0.0


func _ready() -> void:
	hitbox.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_lifetime_remaining += delta
	if _lifetime_remaining >= lifetime:
		queue_free()
	
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	
	if body is BaseEntity:
		(body as BaseEntity).take_damage(damage)
		if enemy_impact and damage > 0:
			SoundManager.play_sound_from_position(enemy_impact, global_position)
	else:
		if environment_impact:
			SoundManager.play_sound_from_position(environment_impact, global_position)
	
	# TODO: Play particle here
	queue_free()


