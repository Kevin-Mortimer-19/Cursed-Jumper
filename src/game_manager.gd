extends MarginContainer

@export var game_world: Node

@export var curse_menu: MarginContainer

@export var HUD: MarginContainer

@export_group("Curse Icons")
@export var no_walk_icon: Texture2D
@export var no_jump_icon: Texture2D
@export var no_move_midair_icon: Texture2D
@export var no_damage_icon: Texture2D
@export var more_enemies_icon: Texture2D
@export var fast_enemies_icon: Texture2D
@export var instant_death_icon: Texture2D
@export var double_gravity_icon: Texture2D
@export var ice_physics_icon: Texture2D

var curse_menu_open: bool = false


func _ready():
	game_world.open_curse_shuffle_menu.connect(toggle_curse_menu)
	game_world.refresh_curse_UI.connect(change_curse_UI)
	
	curse_menu.shuffle.connect(game_world.shuffle_curse)
	curse_menu.shuffle.connect(spend_coin)
	
	curse_menu.lock_curse.connect(game_world.lock_curse)
	curse_menu.lock_curse.connect(spend_coin)
	
	curse_menu.unlock_curse.connect(game_world.unlock_curse)
	curse_menu.unlock_curse.connect(spend_coin)
	
	DialogueManager.dialogue_ended.connect(end_dialogue)
	
	game_world.change_coin_amount.connect(update_coin_UI)
	update_coin_UI()


func _process(_delta):
	if Input.is_action_just_pressed("cancel") and curse_menu_open:
		toggle_curse_menu()


func spend_coin(_msg = {}) -> void:
	game_world._spend_coin(curse_menu.price)
	curse_menu.price_check(game_world.coin_amount)
	update_coin_UI()


func toggle_curse_menu() -> void:
	if curse_menu_open:
		curse_menu.visible = false
		curse_menu_open = false
		get_tree().paused = false
	else:
		curse_menu.price_check(game_world.coin_amount)
		curse_menu.visible = true
		curse_menu_open = true
		get_tree().paused = true


func change_curse_UI(curse_data: Array[int]):
	curse_menu.refresh_curse_UI(find_curse_icon(curse_data[0]),
			find_curse_icon(curse_data[1]),
			find_curse_icon(curse_data[2]))
	
	HUD.refresh_curse_UI(find_curse_icon(curse_data[0]),
			find_curse_icon(curse_data[1]),
			find_curse_icon(curse_data[2]))


func find_curse_icon(data: int) -> Texture2D:
	match data:
		1:
			return no_walk_icon
		2:
			return no_move_midair_icon
		4:
			return no_jump_icon
		8:
			return double_gravity_icon
		16:
			return ice_physics_icon
		32:
			return no_damage_icon
		64:
			return instant_death_icon
		128:
			return fast_enemies_icon
		256:
			return more_enemies_icon
		_:
			return no_walk_icon


func update_coin_UI():
	HUD.update_coin_tracker(game_world.coin_amount)


func end_dialogue(d: DialogueResource) -> void:
	unpause_game()


func pause_game():
	get_tree().paused = true


func unpause_game():
	get_tree().paused = false
