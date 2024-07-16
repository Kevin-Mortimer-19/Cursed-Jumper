class_name DestructibleEntity extends BaseEntity

func _ready() -> void:
	died.connect(queue_free)
