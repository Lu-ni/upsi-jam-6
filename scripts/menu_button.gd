extends Button

@export var hover_scale := 1.01
@export var rotate_amount := 3.0
@export var cycle_time := 0.6

var base_scale : Vector2
var base_rotation : float
var base_position : Vector2

var hover_tween : Tween

func _ready():
	base_scale = scale
	base_rotation = rotation
	base_position = position
	
	pivot_offset = size / 2

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if hover_tween:
		hover_tween.kill()

	scale = base_scale * hover_scale

	hover_tween = create_tween()
	hover_tween.set_loops()
	hover_tween.set_trans(Tween.TRANS_SINE)
	hover_tween.set_ease(Tween.EASE_IN_OUT)

	hover_tween.tween_property(self, "rotation", deg_to_rad(rotate_amount), cycle_time)
	hover_tween.tween_property(self, "rotation", deg_to_rad(-rotate_amount), cycle_time)

func _on_mouse_exited():
	if hover_tween:
		hover_tween.kill()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", base_scale, 0.1)
	tween.tween_property(self, "rotation", base_rotation, 0.1)
