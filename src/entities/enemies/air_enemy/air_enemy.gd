class_name AirEnemy extends Enemy

@export var distance_to_attack: float = 150.0

@export_group("Node References")
@export var sprite: AnimatedSprite2D
@export var player_detection_radius: Area2D
@export var hitbox: Area2D

var target: Player
var direction: Vector2

var _direct_space: PhysicsDirectSpaceState2D
var _query = PhysicsRayQueryParameters2D
var _had_los: bool = false

var _is_attacking: bool = false
var _tween: Tween

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


func _physics_process(delta: float) -> void:
	if not target:
		_wander_state(delta)
	elif not _had_los:
		_query.to = target.global_position
		var result = _direct_space.intersect_ray(_query)
		_had_los = result.is_empty()
		if not _had_los:
			_wander_state(delta)
	elif not _is_attacking:
		_hunt_state(delta)
	else:
		_attack_state()


func _wander_state(_delta: float) -> void:
	sprite.play("default")
	velocity.x = -get_move_speed() if sprite.flip_h else get_move_speed()
	move_and_slide()
	
	# Turn around on hitting wall
	if get_slide_collision_count() > 0:
		sprite.flip_h = !sprite.flip_h



func _hunt_state(_delta: float) -> void:
	sprite.play("attack")
	var target_position:= target.global_position
	direction.x = global_position.x - target_position.x
	_handle_sprite()
	
	_query.to = target.global_position
	var result: bool = _direct_space.intersect_ray(_query).is_empty()
	
	if global_position.distance_to(target_position) <= distance_to_attack and result:
		_is_attacking = true
		_attack_state()
	else:
		velocity.x = -get_move_speed() if sprite.flip_h else get_move_speed()
	

func _attack_state() -> void:
	sprite.play("attack")
	
	if not _tween:
		_tween = create_tween()
		var distance = target.global_position.distance_to(global_position)
		var previous_pos = global_position
		_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		_tween.tween_property(
			self, "global_position", 
			target.global_position, 
			distance/get_move_speed()
		)
		
		_tween.chain().tween_property(
			self, "global_position", 
			previous_pos,
			distance/get_move_speed()
		)
		_tween.set_ease(Tween.EASE_OUT)
		
		_tween.finished.connect(
			func():
				target = null
				_tween = null
				_had_los = false
				_is_attacking = false
				player_detection_radius.set_deferred("monitoring", false)
				await get_tree().process_frame
				player_detection_radius.set_deferred("monitoring", true)
		)
		
		_tween.play()


func _handle_sprite() -> void:
	# TODO: Play idle/move animation
	sprite.flip_h = direction.x < 0






func _on_body_detected(body: Node2D) -> void:
	if body is Player:
		target = body

func _on_hitbox_body_detected(body: Node2D) -> void:
	if body is Player:
		# TODO: Play damage sound effect
		(body as Player).take_damage(damage)












