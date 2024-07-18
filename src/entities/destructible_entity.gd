class_name DestructibleEntity extends BaseEntity

const SOUND_HIT:= preload("res://assets/sounds/destructible/destructible_hit.tres")

func _ready() -> void:
	damaged.connect(SoundManager.play_sound_from_position.bind(SOUND_HIT, global_position))
	died.connect(queue_free)
