class_name Coin extends CharacterBody2D


@export var amount: int = 1
@export var is_falling: bool = false

@export_group("Node References")
@export var sprite: AnimatedSprite2D
@export var area: Area2D

const GRAVITY:= 380

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# TODO: Play pick up sfx
		EventBus.coin_picked_up.emit(amount)
		# TODO: Play pick up animation
		# sprite.play("pick_up")
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_falling: 
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()




