extends Area2D

@export var tutorial: PackedScene

var active: bool = false


func _ready():
	body_entered.connect(start_tutorial)
	EventBus.activate_zone.connect(activate)


func start_tutorial(_body: CharacterBody2D):
	EventBus.start_tutorial.emit(tutorial)
	queue_free()


func activate():
	set_collision_mask_value(2, true)
	print("AAAA")
