class_name InteractableZone extends Area2D

signal interacted(player)

var player_ref: Player



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_instance_valid(player_ref):
		interacted.emit(player_ref)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_ref = body
		EventBus.enter_interactable.emit()
		EventBus.display_interact_tip.emit(true)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_ref = null
		EventBus.exit_interactable.emit()
		EventBus.display_interact_tip.emit(false)


