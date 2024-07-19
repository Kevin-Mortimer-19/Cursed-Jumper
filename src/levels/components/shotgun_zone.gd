extends Area2D


func _ready():
	body_entered.connect(shotgun_get)


func shotgun_get(_b: CharacterBody2D) -> void:
	EventBus.acquire_shotgun.emit()
	queue_free()
