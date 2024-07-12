class_name Enemy extends BaseEntity


func _ready() -> void:
	died.connect(queue_free)


