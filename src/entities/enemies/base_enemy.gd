class_name Enemy extends BaseEntity

@export var sound_hurt: AudioStream

@export_range(0.0, 1.0, 0.01) var coin_drop_chance: float = 1.0
@export_category("Stats")
@export var move_speed: float = 100 : get = get_move_speed
@export var accel: float = 0.2
@export var gravity: float = 98.1
@export var jump_force: float = 80
@export var damage: int = 1



func get_move_speed() -> float:
	return move_speed * 2 if EventBus.faster_enemy_curse_active else move_speed

func _ready() -> void:
	died.connect(_on_died)



func _on_died() -> void:
	if is_queued_for_deletion():
		return
	
	# Play death animation/sound
	SoundManager.play_sound_from_position(sound_hurt, global_position)
	
	var rng:= RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() <= coin_drop_chance:
		EventBus.coin_created.emit(global_position)
	
	queue_free()



