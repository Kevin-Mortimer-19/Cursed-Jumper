extends Node2D


@export var spread_amount_degrees: float
@export var bullet_scene: PackedScene

@export var fire_sound: AudioStream

func _process(delta: float) -> void:
	$Sprite.flip_v = (fmod(abs(rotation_degrees), 360) >= 90 and fmod(abs(rotation_degrees), 360) <= 270)

func shoot(amount: int) -> void:
	SoundManager.play_sound_nonpositional(fire_sound)
	# TODO: Play muzzle flash particle here
	
	var rng:= RandomNumberGenerator.new() 
	for i in range(amount):
		var bullet: Projectile = bullet_scene.instantiate()
		add_child(bullet)
		bullet.set_as_top_level(true)
		(bullet as Node2D).global_transform = global_transform
		bullet.velocity = (global_transform.x * ((1.0 + 0.3 * rng.randf()) * bullet.move_speed)) \
				.rotated(deg_to_rad(rng.randf() * spread_amount_degrees))


