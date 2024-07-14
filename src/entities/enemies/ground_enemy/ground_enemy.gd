extends Enemy

@export_range(0.0, 1.0, 0.01) var coin_drop_chance: float = 1.0
@export_category("Stats")
@export var move_speed: float = 100 : get = get_move_speed
@export var accel: float = 0.2
@export var gravity: float = 98.1
@export var jump_force: float = 80
@export var damage: int = 1

@export_group("Node References")
@export var sprite: Sprite2D
@export var player_detection_radius: Area2D
@export var hitbox: Area2D
@export_subgroup("Raycasts", "raycast_")
@export var raycast_edge: RayCast2D
@export var raycast_edge_2: RayCast2D
@export var raycast_obstacle: RayCast2D
@export var raycast_can_jump_obstacle: RayCast2D

var target: Node2D
var direction: Vector2
var _direct_space: PhysicsDirectSpaceState2D
var _query = PhysicsRayQueryParameters2D

var _had_los: bool = false


func get_move_speed() -> float:
	return move_speed * 2 if EventBus.faster_enemy_curse_active else move_speed


func _ready() -> void:
	player_detection_radius.body_entered.connect(_on_body_detected)
	hitbox.body_entered.connect(_on_hitbox_body_detected)
	died.connect(_on_died)
	
	_direct_space = get_world_2d().direct_space_state
	_query = PhysicsRayQueryParameters2D.create(
			global_position, 
			global_position, 
			0b1, 
			[self.get_rid()]
		)


func _on_body_detected(body: Node2D) -> void:
	if body is Player:
		target = body


func _physics_process(delta: float) -> void:
	if not target:
		return
	# Spotted properly
	elif not _had_los:
		_query.to = target.global_position
		var result = _direct_space.intersect_ray(_query)
		_had_los = result.is_empty()
		if not _had_los:
			return
	
	# We only care about x direction
	direction = global_position.direction_to(target.global_position)
	
	_handle_sprite()
	_apply_gravity(delta)
	_handle_movement()
	
	move_and_slide()


func _handle_movement() -> void:
	if not target:
		return
	
	# If there's a ledge
	if not raycast_edge.is_colliding() and not raycast_edge_2.is_colliding():
		velocity.x = 0
	else:
		velocity.x = direction.normalized().x * get_move_speed()
	
	# If there's a block in the way
	if raycast_obstacle.is_colliding():
		if raycast_can_jump_obstacle.is_colliding():
			velocity.x = 0
		elif is_on_floor():
			# TODO: Play jump animation
			velocity.y = -jump_force
	


func _handle_sprite() -> void:
	# TODO: Play idle/move animation
	sprite.flip_h = direction.x < 0
	$Raycasts.scale.x = sign(direction.x)
 

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_died() -> void:
	# TODO: Play death animation/sound
	
	var rng:= RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() <= coin_drop_chance:
		EventBus.coin_created.emit(global_position)
	
	queue_free()

func _on_hitbox_body_detected(body: Node2D) -> void:
	if body is Player:
		# TODO: Play damage sound effect
		(body as Player).take_damage(damage)










