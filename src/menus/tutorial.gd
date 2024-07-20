extends Control

@export_group("Text")
@export_multiline var subject: String
@export_multiline var main_text: String

@export_group("Node References")
@export var subject_label: Label
@export var main_text_label: Label


func _ready() -> void:
	if subject != "":
		subject_label.text = subject
	if main_text != "":
		main_text_label.text = main_text
