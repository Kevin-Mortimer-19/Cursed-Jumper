extends Label

@export_multiline var text_block: String
@export var first_in_scene: bool
@export var last_in_scene: bool

@export_group("Node References")
@export var next_text_block: Label
@export var close_button: Button

@export_group("Timers")
@export var fade_time: float
@export var delay_time: float
@export var time_before_next: float

signal text_fade_finished


func _ready() -> void:
	modulate.a = 0
	text = text_block
	
	if next_text_block != null:
		var timer_for_next = Timer.new()
		add_child(timer_for_next)
		timer_for_next.one_shot = true
		timer_for_next.wait_time = time_before_next
		text_fade_finished.connect(timer_for_next.start.bind(time_before_next))
		timer_for_next.timeout.connect(next_text_block.fade_in)
	
	if last_in_scene:
		text_fade_finished.connect(reveal_close_button)
	
	if delay_time > 0 and first_in_scene:
		var delay_timer = Timer.new()
		add_child(delay_timer)
		delay_timer.wait_time = delay_time
		delay_timer.timeout.connect(fade_in)
		delay_timer.start()
	elif first_in_scene:
		fade_in()


func fade_in() -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate:a", 1, fade_time)
	tween.play()
	await tween.finished
	text_fade_finished.emit()


func reveal_close_button() -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(close_button, "modulate:a", 1, fade_time)
	tween.play()
