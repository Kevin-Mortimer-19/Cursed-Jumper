extends ColorRect





func animate_transition(animate_in: bool) -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	if animate_in:
		tween.tween_property(self, "color:a", 1.0, 1.0)
	else:
		tween.tween_property(self, "color:a", 0.0, 1.0)
	
	tween.play()
	await tween.finished
	EventBus.transition_finished.emit()
