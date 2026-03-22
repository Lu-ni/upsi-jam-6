extends PanelContainer

signal tutorial_finished

func _ready() -> void:
	add_to_group("tuto_popups")
	var label = $MarginContainer/Label
	if label:
		label.visible_characters = 0

func start_tutorial(msg: String) -> void:
	var label = $MarginContainer/Label
	if not label: return
	
	label.text = msg
	label.visible_characters = 0
	modulate.a = 0.0
	
	var tween = create_tween()
	
	# Fade in the bubble
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Typewriter effect (approx 0.03 seconds per character)
	var type_duration = msg.length() * 0.03
	tween.tween_property(label, "visible_characters", msg.length(), type_duration).set_trans(Tween.TRANS_LINEAR)
	
	# Keep the message visible
	tween.tween_interval(2.0)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	tween.tween_callback(func():
		tutorial_finished.emit()
		queue_free()
	)
