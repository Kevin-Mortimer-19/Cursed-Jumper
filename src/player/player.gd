class_name Player extends CharacterBody2D


@export_category("Node References")
@export var sprite: AnimatedSprite2D


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


@export_group("Modifiers", "modifiers_")
@export_flags(
	"Can Move Ground:1", "Can Move Air:2", "Can Swim:4", "Can Jump:8",
) var modifiers_move_options: int

@export_flags(
	"Can Double Jump:1", "Double Gravity:2", "Ice Physics:4"
) var modifiers_movement: int

@export_flags(
	"Can Deal Damage", "Dies Instantly", 
) var modifiers_combat: int

var _was_on_floor: bool = false
var _coyote_timer: Timer
var _jump_buffer_timer: Timer



func get_movement() -> float:
	return Input.get_axis("move_left", "move_right")

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
	return modifiers_movement & 1

#endregion


func _ready() -> void:
	_setup_timers()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_move()
	_handle_jump()
	
	_was_on_floor = is_on_floor()
	
	move_and_slide()


func _handle_move() -> void:
	var input = get_movement()
	var rate: float
	if is_on_floor():
		if can_move_ground():
			rate = ground_accel if input else ground_friction
			velocity.x = lerp(velocity.x, input * ground_speed, rate)
	elif can_control_air():
		rate = air_accel if input else ground_friction
		velocity.x = lerp(velocity.x, input * air_speed, rate)


func _apply_gravity(delta: float) -> void:
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
	# Jump buffer check
	elif not _was_on_floor and is_on_floor():
		if not _jump_buffer_timer.is_stopped():
			velocity.y = -jump_strength_full if Input.is_action_pressed("jump") else -jump_strength_half






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







