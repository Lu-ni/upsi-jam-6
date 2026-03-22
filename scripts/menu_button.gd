extends Button

@export var hover_scale := 1.2
@export var hover_rotation := 10.0
@export var anim_time := 0.15

var tween: Tween

func _ready():
	# Ensure scaling/rotation happens from the center
	set_anchors_preset(Control.PRESET_CENTER)
	pivot_offset = size / 2

	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", Vector2.ONE * hover_scale, anim_time)
	tween.tween_property(self, "rotation_degrees", hover_rotation, anim_time)

func _on_exit():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", Vector2.ONE, anim_time)
	tween.tween_property(self, "rotation_degrees", 0.0, anim_time)
