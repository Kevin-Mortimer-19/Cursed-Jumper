class_name LeverInteractable extends Node2D

signal interacted(player)

@export var node_to_trigger: Node
@export var interact_sound: AudioStream
@export var area_flag: int


func _ready() -> void:
	%InteractableZone.interacted.connect(_on_lever_interacted)
	
	if node_to_trigger and is_instance_valid(node_to_trigger):
		if node_to_trigger.has_method("trigger"):
			interacted.connect(node_to_trigger.trigger)
	

func _on_lever_interacted(player: Player) -> void:
	%InteractableZone.monitoring = false
	interacted.emit(player)
	$Sprite2D.flip_h = !$Sprite2D.flip_h
	if interact_sound:
		SoundManager.play_sound_from_position(interact_sound, global_position)
	if area_flag:
		GameState.set_area_flag(area_flag)




