extends MarginContainer

@export var game_world: Node
@export var curse_menu: MarginContainer
@export var HUD: MarginContainer
@export var pause_modulate: ColorRect
@export var game_start_text: DialogueResource
@export var acquire_shotgun_text: DialogueResource

@export_group("Tutorials")
@export var movement_tutorial: PackedScene
@export var gun_tutorial: PackedScene

@export_group("Ending Scenes")
@export var OVERSEER_END: PackedScene
@export var SHOTGUN_END: PackedScene

@export_group("Dialogue Portraits")
@export var shotgun_portrait: Texture2D
@export var overseer_portrait: Texture2D
@export var prisoner_1_portrait: Texture2D
@export var prisoner_2_portrait: Texture2D


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



const CurseDescriptions: Dictionary = {
	"NoWalk": "Cannot move on the ground voluntarily.",
	"NoMoveAir": "Cannot move in the air voluntarily.",
	"NoJump": "Cannot manually jump.",
	"DoubleGravity": "Gravity is doubled.",
	"IcePhysics": "Maneuverability greatly reduced.",
	"NoDamage": "Cannot deal damage to foes.",
	"InstantDeath": "Die in one hit.",
	"FastEnemy": "Enemies move much more quickly.",
	"MoreEnemy": "Enemies are more plentiful.",
}

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
	
	GameState.end_game.connect(transition_to_end_screen)
	
	EventBus.acquire_shotgun.connect(acquire_shotgun)
	
	EventBus.start_tutorial.connect(display_tutorial)
	EventBus.movement_tutorial.connect(open_move_tutorial)
	EventBus.gun_tutorial.connect(open_gun_tutorial)
	
	DialogueManager.dialogue_ended.connect(end_dialogue)
	EventBus.switch_portrait.connect(switch_dialogue_portrait)
	
	PauseMenu.visibility_changed.connect(
		func():
			$SubViewportContainer.mouse_filter = (
				MOUSE_FILTER_PASS if not PauseMenu.visible else MOUSE_FILTER_IGNORE
			)
			pause_modulate.visible = PauseMenu.visible
	)
	
	game_world.change_coin_amount.connect(update_coin_UI)
	
	HUD.set_up_healthbar(game_world.player)
	update_coin_UI()
	
	_display_dialogue_at_game_start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if curse_menu_open:
			toggle_curse_menu()
		else:
			get_tree().paused = true
			PauseMenu.show()


func transition_to_end_screen() -> void:
	DialogueManager.dialogue_ended.disconnect(end_dialogue)
	var end_scene
	if GameState.ending_flags & 1:
		end_scene = SHOTGUN_END
	elif GameState.ending_flags & 2:
		end_scene = OVERSEER_END
	call_deferred("_end_game", end_scene)


func _end_game(ending: PackedScene) -> void:
	await ScreenTransition.animate_transition(true)
	get_tree().change_scene_to_packed(ending)


func spend_coin(_msg = {}) -> void:
	game_world._spend_coin(curse_menu.price)
	curse_menu.price_check(game_world.coin_amount)
	update_coin_UI()


func toggle_curse_menu() -> void:
	if curse_menu_open:
		curse_menu_open = false
		await curse_menu.animate_exit()
		get_tree().paused = false
	else:
		curse_menu.price_check(game_world.coin_amount)
		await curse_menu.animate_enter()
		curse_menu_open = true
		get_tree().paused = true


func change_curse_UI(curse_data: Array[int]):
	curse_menu.refresh_curse_UI(find_curse_icon(curse_data[0]),
			find_curse_icon(curse_data[1]))
	
	HUD.refresh_curse_UI(find_curse_icon(curse_data[0]),
			find_curse_icon(curse_data[1]))


func find_curse_icon(data: int) -> Array:
	match data:
		1:
			return [no_walk_icon, CurseDescriptions.NoWalk]
		2:
			return [no_move_midair_icon, CurseDescriptions.NoMoveAir]
		4:
			return [no_jump_icon, CurseDescriptions.NoJump]
		8:
			return [double_gravity_icon, CurseDescriptions.DoubleGravity]
		16:
			return [ice_physics_icon, CurseDescriptions.IcePhysics]
		32:
			return [no_damage_icon, CurseDescriptions.NoDamage]
		64:
			return [instant_death_icon, CurseDescriptions.InstantDeath]
		128:
			return [fast_enemies_icon, CurseDescriptions.FastEnemy]
		256:
			return [more_enemies_icon, CurseDescriptions.MoreEnemy]
		_:
			return [no_walk_icon, CurseDescriptions.NoWalk]


func _display_dialogue_at_game_start() -> void:
	await get_tree().process_frame
	
	DialogueManager.show_dialogue_balloon(game_start_text, "game_start")
	get_tree().paused = true
	
	await DialogueManager.dialogue_ended
	await ScreenTransition.animate_transition(false)


func switch_dialogue_portrait(char_name: String):
	var portrait: Texture2D = null
	match char_name:
		"shotgun":
			portrait = shotgun_portrait
		"overseer":
			portrait = overseer_portrait
		"prisoner_1":
			portrait = prisoner_1_portrait
		"prisoner_2":
			portrait = prisoner_2_portrait
	EventBus.change_dialogue_portrait.emit(portrait)


func acquire_shotgun() -> void:
	DialogueManager.show_dialogue_balloon(acquire_shotgun_text, "shotgun_3")
	get_tree().paused = true


func update_coin_UI():
	HUD.update_coin_tracker(game_world.coin_amount)


func end_dialogue(_d: DialogueResource) -> void:
	if GameState.dialogue_unpause_override:
		GameState.dialogue_unpause_override = false
	else:
		unpause_game()


func display_tutorial(tutorial: PackedScene):
	var t_reference = tutorial.instantiate()
	add_child(t_reference)
	call_deferred("pause_game")


func open_move_tutorial():
	display_tutorial(movement_tutorial)


func open_gun_tutorial():
	display_tutorial(gun_tutorial)


func pause_game():
	get_tree().paused = true


func unpause_game():
	get_tree().paused = false

