extends Area2D

@export var dialogue: DialogueResource
@export var first_line: String


func _ready():
	body_entered.connect(_on_activate)


func _on_activate(_body: CharacterBody2D):
	DialogueManager.show_dialogue_balloon(dialogue, first_line)
	get_tree().paused = true
	queue_free()
