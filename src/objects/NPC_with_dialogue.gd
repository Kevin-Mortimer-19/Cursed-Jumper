@tool
extends Area2D

@export var dialogue: DialogueResource
@export var first_line: String
@export var sprite: Sprite2D
@export var sprite_image: Texture2D :
	set(val):
		sprite_image = val
		if val:
			sprite.texture = sprite_image

var player_in_area: bool = false


func _ready():
	sprite.texture = sprite_image
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta):
	if Input.is_action_just_pressed("interact") and player_in_area:
		DialogueManager.show_example_dialogue_balloon(dialogue, first_line)
		get_tree().paused = true


func _on_body_entered(_b = PhysicsBody2D):
	player_in_area = true


func _on_body_exited(_b = PhysicsBody2D):
	player_in_area = false
