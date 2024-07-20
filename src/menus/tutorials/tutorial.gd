extends Control

@export_group("Data")
@export_multiline var subject: String
@export_multiline var main_text: String
@export var next_tutorial: PackedScene
@export var next_dialogue: DialogueResource
@export var next_dialogue_start: String


@export_group("Node References")
@export var subject_label: Label
@export var main_text_label: Label
@export var close_button: Button


func _ready() -> void:
	if subject != "":
		subject_label.text = subject
	if main_text != "":
		main_text_label.text = main_text
	close_button.pressed.connect(close_tutorial)


func close_tutorial() -> void:
	get_tree().paused = false
	if next_tutorial != null:
		EventBus.start_tutorial.emit(next_tutorial)
	elif next_dialogue != null:
		DialogueManager.show_example_dialogue_balloon(next_dialogue, next_dialogue_start)
		get_tree().paused = true
	queue_free()
