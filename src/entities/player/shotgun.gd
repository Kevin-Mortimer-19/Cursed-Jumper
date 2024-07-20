class_name Shotgun extends Node2D

@export var sprite: AnimatedSprite2D
@export var spread_amount_degrees: float
@export var bullet_scene: PackedScene
@export var particles_scene: PackedScene

@export_group("Audio")
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream

func _process(_delta: float) -> void:
	var is_left_side:= (fmod(abs(rotation_degrees), 360) >= 90 and fmod(abs(rotation_degrees), 360) <= 270)
	sprite.flip_v = is_left_side
	$Root.position.y = -3 if is_left_side else 3

func shoot(amount: int, does_damage: bool = true) -> void:
	SoundManager.play_sound_nonpositional(fire_sound)
	# TODO: Play muzzle flash particle here
	var flash: BurstParticleGroup2D = particles_scene.instantiate()
	add_child(flash)
	flash.set_as_top_level(true)
	flash.global_transform = global_transform
	
	var rng:= RandomNumberGenerator.new() 
	for i in range(amount):
		var bullet:= bullet_scene.instantiate() as Projectile
		bullet.can_damage_enemy = does_damage
		
		add_child(bullet)
		bullet.owner = get_parent()
		bullet.set_as_top_level(true)
		(bullet as Node2D).global_transform = global_transform
		bullet.velocity = (global_transform.x * ((1.0 + 0.3 * rng.randf()) * bullet.move_speed)) \
				.rotated(deg_to_rad(rng.randf() * spread_amount_degrees))


