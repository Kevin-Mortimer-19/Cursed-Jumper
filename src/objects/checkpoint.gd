extends Area2D

# May be obsolete because of area_entered and area_exited
signal checkpoint_entered
signal checkpoint_exited
signal checkpoint_activated

## Checkpoint can only be used after this is set to true, when the player is cursed initially
var activated: bool = false

## Tracks when the player is in the checkpoint area
var player_in_checkpoint: bool


func _ready():
	body_entered.connect(checkpoint_edge.bind(true))
	body_exited.connect(checkpoint_edge.bind(false))
	checkpoint_entered.connect(enter_checkpoint)
	checkpoint_exited.connect(exit_checkpoint)
	EventBus.acquire_shotgun.connect(activate_checkpoint)


func _physics_process(_delta):
	if Input.is_action_just_pressed("interact") and player_in_checkpoint and activated:
		checkpoint_activated.emit()


func checkpoint_edge(_b: CharacterBody2D, entrance: bool) -> void:
	if entrance:
		checkpoint_entered.emit()
	else:
		checkpoint_exited.emit()


func activate_checkpoint() -> void:
	activated = true


func enter_checkpoint():
	if activated:
		player_in_checkpoint = true
		EventBus.enter_interactable.emit()
		EventBus.display_interact_tip.emit(true)


func exit_checkpoint():
	if activated:
		player_in_checkpoint = false
		EventBus.exit_interactable.emit()
		EventBus.display_interact_tip.emit(false)
