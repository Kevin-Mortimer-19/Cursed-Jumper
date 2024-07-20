extends Area2D

# May be obsolete because of area_entered and area_exited
signal checkpoint_entered
signal checkpoint_exited
signal checkpoint_activated

## Tracks when the player is in the checkpoint area
var player_in_checkpoint: bool

## UI element that displays control tooltip to open checkpoint menu; 
## can be changed from Label in the future
@export var checkpoint_activate_UI: Label


func _ready():
	body_entered.connect(checkpoint_edge.bind(true))
	body_exited.connect(checkpoint_edge.bind(false))
	checkpoint_entered.connect(enter_checkpoint)
	checkpoint_exited.connect(exit_checkpoint)


func _physics_process(_delta):
	if Input.is_action_just_pressed("interact") and player_in_checkpoint:
		checkpoint_activated.emit()


func checkpoint_edge(_b: CharacterBody2D, entrance: bool) -> void:
	if entrance:
		checkpoint_entered.emit()
	else:
		checkpoint_exited.emit()


func enter_checkpoint():
	player_in_checkpoint = true
	checkpoint_activate_UI.visible = true


func exit_checkpoint():
	player_in_checkpoint = false
	checkpoint_activate_UI.visible = false
