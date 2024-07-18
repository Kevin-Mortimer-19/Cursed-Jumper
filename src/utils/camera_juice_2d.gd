## A generic 2D camera with some built-in utility and juice.
class_name CameraJuice2D extends Camera2D

## Movement
@export var lean_to_mouse: bool = false
@export var camera_damping: float = 0.9

@export var target: Node2D
@export var additional_targets: Array[Node2D] = []

### SCREEN SHAKE

## How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
## Noise returns values in the range (-1, 1)
## So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 20.0
@export var NOISE_SWAY_STRENGTH: float = 10.0
## The starting range of possible offsets using random values
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
## Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 3.0

# variable decay
var decay_rate: float = SHAKE_DECAY_RATE

@onready var noise: FastNoiseLite = FastNoiseLite.new()
# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0
@onready var rand = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	noise.frequency = 2
	# Connect the screen_shake signal to this camera.
	EventBus.screenshake_requested.connect(apply_noise_shake)

func apply_noise_shake(strength: float = NOISE_SHAKE_STRENGTH, decay: float = SHAKE_DECAY_RATE) -> void:
	shake_strength = max(shake_strength, strength)
	decay_rate = min(decay_rate, decay)

func _physics_process(delta: float) -> void:
	# Track targets as needed
	track_targets()
	# Camera shake
	do_shake(delta)
	# Leans towards mouse
	mouse_lean()



## Have the camera move around to track targets.
func track_targets() -> void:
	if not target:
		return
	## Track target(s)
	if additional_targets.is_empty():
		## Track only main target
		self.global_position = lerp(global_position, target.global_position, 0.08)
	else:
		## Track an average point between all targets, weighted towards main target
		var avg_pos: Vector2 = target.global_position * camera_damping
		# Average positions
		for t in additional_targets:
			avg_pos += t.global_position * ((1.0 - camera_damping) / additional_targets.size())
		avg_pos /= additional_targets.size()
		# Move towards
		self.global_position = lerp(global_position, avg_pos, 0.08)

## Do the actual screen shaking
func do_shake(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0, decay_rate * delta)
	var shake_offset:= Vector2.ZERO
	shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, shake_strength)
	# Shake by adjusting camera.offset so we can move the camera around the level via its position
	self.offset.x = snappedf(shake_offset.x, 0.05)
	self.offset.y = snappedf(shake_offset.y, 0.05)

## Lean towards the mouse
func mouse_lean() -> void:
	if not lean_to_mouse:
		return
	# Camera easing towards mouse
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dir = mouse_pos - self.global_position
	if dir.length() > 25.0:
		self.offset = lerp(offset, offset + camera_damping * dir, 0.1)



## Get the noise offset
func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)
