extends MarginContainer

@export var game_world: Node

@export var curse_menu: MarginContainer

var curse_menu_open: bool = false


func _ready():
	game_world.open_curse_shuffle_menu.connect(toggle_curse_menu)


func _process(_delta):
	if Input.is_action_just_pressed("cancel") and curse_menu_open:
		toggle_curse_menu()


func toggle_curse_menu() -> void:
	if curse_menu_open:
		curse_menu.visible = false
		curse_menu_open = false
		get_tree().paused = false
	else:
		curse_menu.visible = true
		curse_menu_open = true
		get_tree().paused = true

