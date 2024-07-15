class_name MovingPlatform extends PathFollow2D

## Is a one and done animation.
@export var is_one_shot: bool = false
## How quickly the platform moves along the path.
@export var move_speed: float
## Whether the platform is currently moving.
@export var is_currently_moving: bool = false
## How long the platform waits at its destination before moving again.
@export var wait_time_at_ends: float = 0.0


var _is_reversing: bool = false

var _wait_timer: Timer

func _ready() -> void:
	if wait_time_at_ends > 0.0:
		_wait_timer = Timer.new()
		_wait_timer.one_shot = true
		_wait_timer.wait_time = wait_time_at_ends
		add_child(_wait_timer)

func trigger(__) -> void:
	is_currently_moving = !is_currently_moving
	if wait_time_at_ends > 0.0:
		_wait_timer.start()



func _physics_process(delta: float) -> void:
	if is_currently_moving and (not _wait_timer or (_wait_timer.is_stopped())):
		if not _is_reversing:
			if progress_ratio < 1.0:
				progress_ratio += delta * move_speed
			elif progress_ratio >= 1.0:
				if not is_one_shot:
					_is_reversing = true
					if _wait_timer:
						_wait_timer.start()
				else:
					set_physics_process(false)
		else:
			if progress_ratio > 0.0:
				progress_ratio -= delta * move_speed
			elif progress_ratio <= 0.0:
				_is_reversing = false
				if _wait_timer:
					_wait_timer.start()


