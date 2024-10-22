class_name Player extends BaseEntity

signal jump_started
signal jump_landed
signal death_finished

@export_category("Node References")
@export var sprite: AnimatedSprite2D
var shotgun: Shotgun

@export_category("Character Properties")
@export_group("Movement Stats")
@export var jump_strength_full: float = 100
@export var jump_strength_half: float = 50
@export var gravity: float = 9.81

@export_subgroup("Ground", "ground_")
@export var ground_speed: float = 50.0
@export_range(0.0, 1.0, 0.01) var ground_accel: float
@export_range(0.0, 1.0, 0.01) var ground_friction: float

@export_subgroup("Air", "air_")
@export var air_speed: float = 50.0
@export_range(0.0, 1.0, 0.01) var air_accel: float
@export_range(0.0, 1.0, 0.01) var air_friction: float

@export_group("Move Feel")
## Buffer window you have after falling off a ledge where you can still jump.
@export var coyote_time: float = 0.15
## Buffer window that buffers a jump just before you hit the ground.
@export var jump_buffer_window: float = 0.15


@export_category("Combat")
@export_group("Attacking")
@export var number_of_shots_per_fire: int = 6
## Damage dealt per bullet.
@export var bullet_damage: int = 2

@export var num_shots_before_reload: int = 2
@export var minimum_time_between_shots: float = 0.2
@export var time_to_reload: float = 1.0
@export var knockback_amount: float = 400

@export_group("Modifiers", "modifiers_")
@export_flags(
	"Can Move Ground:1", "Can Move Air:2", "Can Swim:4", "Can Jump:8",
) var modifiers_move_options: int

@export_flags(
	"Can Double Jump:1", "Double Gravity:2", "Ice Physics:4"
) var modifiers_movement: int

@export_flags(
	"Can Deal Damage:1", "Dies Instantly:2", "Fast Enemies:4", "More Enemies:8"
) var modifiers_combat: int

@export_category("Audio")
@export var sound_hurt: AudioStream
@export var sound_jump: AudioStream
@export var sound_jump_land: AudioStream


## Prevents movement for the purposes of death
var is_dead_locked: bool = false

var shots_remaining: int = 2
var _has_double_jumped: bool = false

var _coyote_timer: Timer
var _jump_buffer_timer: Timer
var _reload_timer: Timer
var _minimum_cd_timer: Timer

var _was_on_floor: bool = false

const SHOTGUN_SCENE = preload("res://src/entities/player/shotgun.tscn")


## Bit flag used to keep track of which curses are active.
## 1: Cannot walk
## 2: Cannot move midair
## 4: Cannot jump
## 8: Double gravity
## 16: Ice physics
## 32: No damage
## 64: Die instantly
## 128: Fast enemies
## 256: More enemies
var curse_1: int = 0
var curse_2: int = 0

var curses: Array[int] = []
var curse_locks: Array[bool] = [false, false]

var rng: RandomNumberGenerator

signal curses_applied(curses: Array[int])


func get_movement() -> float:
	return Input.get_axis("move_left", "move_right")

func take_damage(amount: int) -> void:
	if has_die_oneshot():
		super(max_health)
	else:
		super(amount)

func heal() -> void:
	cur_health = max_health
	healed.emit()


#region Modifiers
func can_move_ground() -> bool:
	return modifiers_move_options & 1

func can_control_air() -> bool:
	return modifiers_move_options & 2

func can_swim() -> bool:
	return modifiers_move_options & 4

func can_jump() -> bool:
	return modifiers_move_options & 8



func can_double_jump() -> bool:
	return modifiers_movement & 1 and not _has_double_jumped

func has_double_gravity() -> bool:
	return modifiers_movement & 2

func has_ice_physics() -> bool:
	return modifiers_movement & 4



func can_deal_damage() -> bool:
	return modifiers_combat & 1

func has_die_oneshot() -> bool:
	return modifiers_combat & 2



#endregion


func _ready() -> void:
	damaged.connect(_animate_damage)
	died.connect(_animate_death)
	
	jump_started.connect(_animate_jump_up)
	jump_landed.connect(_animate_jump_land)
	
	_setup_timers()
	shots_remaining = num_shots_before_reload
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	curses = [curse_1, curse_2]
	
	EventBus.acquire_shotgun.connect(_acquire_shotgun)


func _unhandled_input(event: InputEvent) -> void:
	if is_dead_locked:
		return
	
	if event is InputEventMouseButton:
		var mouse = event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_handle_attack()
	
	if event is InputEventMouseMotion:
		var mouse_pos:= get_global_mouse_position()
		sprite.flip_h = sign(mouse_pos.x - global_position.x) < 0
		if shotgun != null:
			shotgun.look_at(mouse_pos)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	if not is_dead_locked:
		_handle_move()
		_handle_jump()
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.03)
		if snappedf(velocity.x, 0.1) == 0.0:
			death_finished.emit()
	
	_was_on_floor = is_on_floor()
	
	move_and_slide()


func _handle_move() -> void:
	var input = get_movement()
	var speed: float = 0
	var rate: float = ground_friction
	if is_on_floor():
		if can_move_ground():
			rate = ground_accel if input else ground_friction
			speed = input * ground_speed
		else:
			speed = 0
			rate = ground_friction
	elif can_control_air():
		rate = air_accel if input else air_friction
		speed = input * air_speed
	else:
		speed = velocity.x
		rate = 1.0
	
	if has_ice_physics():
		rate = 0.03
	
	velocity.x = lerp(velocity.x, speed, rate)


func _apply_gravity(delta: float) -> void:
	if has_double_gravity():
		delta *= 1.5
	
	if not is_on_floor():
		velocity.y += gravity * delta


func _handle_jump() -> void:
	if can_jump():
		# Full jump
		if Input.is_action_just_pressed("jump"):
			if (
				is_on_floor()
				or can_double_jump() 
				or not _coyote_timer.is_stopped()
			):
				velocity.y = -jump_strength_full
				if not is_on_floor():
					_has_double_jumped = true
				
				jump_started.emit()
			# Begin jump buffer
			else:
				_jump_buffer_timer.start()
		# Half jump
		if Input.is_action_just_released("jump"):
			if velocity.y <= -jump_strength_half:
				velocity.y = -jump_strength_half
	
	# Coyote time
	if _was_on_floor and not is_on_floor():
		_coyote_timer.start()
	# Jump buffer check / just landed
	elif not _was_on_floor and is_on_floor():
		_has_double_jumped = false
		if not _jump_buffer_timer.is_stopped():
			velocity.y = -jump_strength_full if Input.is_action_pressed("jump") else -jump_strength_half
			jump_started.emit()
		else:
			jump_landed.emit()


func _handle_attack() -> void:
	# Not reloading, not in the brief window in between, and has shotgun
	if shots_remaining <= 0 or not _minimum_cd_timer.is_stopped() or shotgun == null:
		return
	
	shots_remaining -= 1
	_minimum_cd_timer.start()
	var mouse_dir:= global_position.direction_to(get_global_mouse_position())
	velocity = -mouse_dir * knockback_amount
	_reload_timer.start()
	shotgun.shoot(number_of_shots_per_fire, can_deal_damage())
	
	# Counts as a jump if going vertically
	if velocity.y <= 0 and velocity.dot(Vector2.UP) > 0.65:
		jump_started.emit()


func _acquire_shotgun() -> void:
	shotgun = SHOTGUN_SCENE.instantiate()
	add_child(shotgun)
	shotgun.position = Vector2(0,-8)
	EventBus.activate_zone.emit()
	call_deferred("generate_curses")


## Helpers
func _setup_timers() -> void:
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	_coyote_timer.wait_time = coyote_time
	add_child(_coyote_timer)
	
	_jump_buffer_timer = Timer.new()
	_jump_buffer_timer.one_shot = true
	_jump_buffer_timer.wait_time = jump_buffer_window
	add_child(_jump_buffer_timer)
	
	_reload_timer = Timer.new()
	_reload_timer.one_shot = true
	_reload_timer.wait_time = time_to_reload
	# Automatically reload
	_reload_timer.timeout.connect(_reload)
	add_child(_reload_timer)
	
	_minimum_cd_timer = Timer.new()
	_minimum_cd_timer.one_shot = true
	_minimum_cd_timer.wait_time = minimum_time_between_shots
	add_child(_minimum_cd_timer)


func _reload() -> void:
	shots_remaining = num_shots_before_reload
	
	if not is_dead_locked:
		if shotgun != null:
			SoundManager.play_sound_nonpositional(shotgun.reload_sound)
		var tween:= create_tween()
		tween.tween_property(shotgun.sprite, "rotation_degrees", 360, 0.25)
		tween.chain().tween_property(shotgun.sprite, "rotation_degrees", 0, 0)


#region Curses


func generate_curses():
	var curse_list: Array[int] = []
	for i in 2:
		curse_list.append(generate_random_from_set(1,8,curse_list))
		curses[i] |= apply_curse(curse_list[i])
	curses_applied.emit(curses)


## Recursive function to generate a random number between values start and end (inclusve).
## If the value generated matches a value within the exclusions set,
## the function will try again until it finds a unique value.
func generate_random_from_set(start: int, end: int, exclusions: Array[int]) -> int:
	var candidate = rng.randi_range(start, end)
	if exclusions.has(candidate) or candidate == 9:
		return generate_random_from_set(start, end, exclusions)
	else:
		return candidate


## Translates a randomly generated number from 1-9
## into a curse that is then applied to the player.
func apply_curse(number: int) -> int:
	match number:
		1: # Cannot walk
			modifiers_move_options ^= 1
			return 1
		2: # Cannot move midair
			modifiers_move_options ^= 2
			return 2
		3: # Cannot jump
			modifiers_move_options ^= 8
			return 4
		4: # Double gravity
			modifiers_movement |= 2
			return 8
		5: # Ice physics
			modifiers_movement |= 4
			return 16
		6: # Deal no damage
			modifiers_combat ^= 1
			return 32
		7: # Die instantly
			modifiers_combat |= 2
			return 64
		8: # Fast enemies
			modifiers_combat |= 4
			EventBus.faster_enemy_curse_active = true
			return 128
		9: # More enemies
			modifiers_combat |= 8
			return 256
		_: # Default case
			return 0


func remove_curse(number: int) -> int:
	match number:
		1: # Cannot walk
			modifiers_move_options |= 1
			return 1
		2: # Cannot move midair
			modifiers_move_options |= 2
			return 2
		3: # Cannot jump
			modifiers_move_options |= 8
			return 4
		4: # Double gravity
			modifiers_movement ^= 2
			return 8
		5: # Ice physics
			modifiers_movement ^= 4
			return 16
		6: # Deal no damage
			modifiers_combat |= 1
			return 32
		7: # Die instantly
			modifiers_combat ^= 2
			return 64
		8: # Fast enemies
			modifiers_combat ^= 4
			EventBus.faster_enemy_curse_active = false
			return 128
		9: # More enemies
			modifiers_combat ^= 8
			return 256
		_: # Default case
			return 0


func translate_rn_into_curse_data(rn: int) -> int:
	match rn:
		1: # Cannot walk
			return 1
		2: # Cannot move midair
			return 2
		3: # Cannot jump
			return 4
		4: # Double gravity
			return 8
		5: # Ice physics
			return 16
		6: # Deal no damage
			return 32
		7: # Die instantly
			return 64
		8: # Fast enemies
			return 128
		9: # More enemies
			return 256
		_: # Default case
			return 0


func translate_curse_data_into_index(data: int) -> int:
	match data:
		1: # Cannot walk
			return 1
		2: # Cannot move midair
			return 2
		4: # Cannot jump
			return 3
		8: # Double gravity
			return 4
		16: # Ice physics
			return 5
		32: # Deal no damage
			return 6
		64: # Die instantly
			return 7
		128: # Fast enemies
			return 8
		256: # More enemies
			return 9
		_: # Default case
			return 0


func shuffle_curse():
	if curse_locks == [true, true]:
		pass
	else:
		var curse_to_shuffle = find_unlocked_curse_index()
		var current_curses: Array[int] = []
		for i in curses:
			current_curses.append(translate_curse_data_into_index(i))
		var new_curse = generate_random_from_set(1,8,current_curses)
		remove_curse(translate_curse_data_into_index(curses[curse_to_shuffle]))
		curses[curse_to_shuffle] = apply_curse(new_curse)
		curses_applied.emit(curses)


func find_unlocked_curse_index() -> int:
	# Check again to make sure we don't enter an infinite loop
	# by accidentally calling this function
	if curse_locks == [true, true, true]:
		return -1
	else:
		var candidate = rng.randi_range(0,1)
		if curse_locks[candidate]:
			return find_unlocked_curse_index()
		else:
			return candidate


func lock_curse(index: int) -> void:
	curse_locks[index] = true


func unlock_curse(index: int) -> void:
	curse_locks[index] = false

#endregion



#region Animation

func _animate_damage() -> void:
	# Sound effect
	SoundManager.play_sound_nonpositional(sound_hurt)
	
	EventBus.hitfreeze_requested.emit(0.1, 0.25)
	EventBus.screenshake_requested.emit(3, 0.50)
	
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.15)
	tween.parallel().tween_property(sprite, "self_modulate", Color(5, 5, 5), 0.15)
	tween.chain().tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.15)
	tween.chain().tween_property(sprite, "scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(sprite, "self_modulate", Color.WHITE, 0.1)
	
	tween.play()

func _animate_death() -> void:
	## Don't repeatedly die
	if is_dead_locked:
		return
	
	EventBus.hitfreeze_requested.emit(0.1, 1)
	is_dead_locked = true
	shotgun.sprite.stop()
	sprite.play("death")
	# TODO: UI prompt to respawn?
	await death_finished
	await get_tree().create_timer(1.0).timeout
	EventBus.player_respawn_requested.emit()



func _animate_jump_up() -> void:
	# Sound effect
	SoundManager.play_sound_nonpositional(sound_jump)
	
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	# squeeze
	tween.tween_property(sprite, "scale", Vector2(0.8, 1.3), 0.15)
	# normal
	tween.chain().tween_property(sprite, "scale", Vector2.ONE, 0.1)
	tween.play()

func _animate_jump_land() -> void:
	# Sound effect
	SoundManager.play_sound_nonpositional(sound_jump_land)
	
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	# squash
	tween.tween_property(sprite, "scale", Vector2(1.3, 0.8), 0.1)
	# normal
	tween.chain().tween_property(sprite, "scale", Vector2.ONE, 0.1)
	tween.play()


#endregion
