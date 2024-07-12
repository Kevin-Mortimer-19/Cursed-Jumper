class_name CameraJuice2D extends Camera2D



@export var target: Node2D
@export_range(0, 1, .01) var lerp_speed: float = 0.1
@export_range(0, 1, .01) var leeway_percent: float

var _allowed_range: Vector2


func _ready() -> void:
	_allowed_range = get_viewport_rect().size * leeway_percent


func _physics_process(_delta: float) -> void:
	var distance_from_target = target.global_position.distance_to(global_position)
	
	if distance_from_target > _allowed_range.length():
		var target_position = target.global_position
		global_position = lerp(global_position, target_position, lerp_speed)






