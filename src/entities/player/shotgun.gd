extends Node2D


@export var spread_amount_degrees: float
@export var bullet_scene: PackedScene

@export var fire_sound: AudioStream

func _process(_delta: float) -> void:
	var is_left_side:= (fmod(abs(rotation_degrees), 360) >= 90 and fmod(abs(rotation_degrees), 360) <= 270)
	$Sprite.flip_v = is_left_side
	$Sprite.offset.y = -3 if is_left_side else 3

func shoot(amount: int, does_damage: bool = true) -> void:
	SoundManager.play_sound_nonpositional(fire_sound)
	# TODO: Play muzzle flash particle here
	
	var rng:= RandomNumberGenerator.new() 
	for i in range(amount):
		var bullet:= bullet_scene.instantiate() as Projectile
		if not does_damage:
			bullet.damage = 0
		
		add_child(bullet)
		bullet.set_as_top_level(true)
		(bullet as Node2D).global_transform = global_transform
		bullet.velocity = (global_transform.x * ((1.0 + 0.3 * rng.randf()) * bullet.move_speed)) \
				.rotated(deg_to_rad(rng.randf() * spread_amount_degrees))


