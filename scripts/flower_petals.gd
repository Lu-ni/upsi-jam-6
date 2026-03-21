extends GPUParticles2D

var ready_to_blow: bool = true

var pink_color: Color = Color(1.0, 0.65, 0.85, 1.0)
var purple_color: Color = Color(0.85, 0.6, 1.0, 1.0)

@export var fade_start: float = 0.7
@export var fade_end: float = 1.0
var target: Node2D = null

func _ready() -> void:
	_setup_gradient()

func _setup_gradient():
	var gradient := Gradient.new()
	for i in range(10):
		var t = i / 9.0
		var rand_color = pink_color.lerp(purple_color, randf())
		gradient.add_point(t, Color(rand_color.r, rand_color.g, rand_color.b, 1.0))
	gradient.add_point(fade_end, Color(1, 1, 1, 0))

	var tex := GradientTexture1D.new()
	tex.gradient = gradient

	var mat := process_material as ParticleProcessMaterial
	mat.color_ramp = tex

func burst_in_direction(dir: Vector2):
	var mat := process_material as ParticleProcessMaterial
	mat.direction = Vector3(dir.x, dir.y, 0).normalized()

	emitting = false
	emitting = true
	ready_to_blow = false

func _process(_delta: float) -> void:
	if ready_to_blow and Input.is_action_just_pressed("petals"):
		ready_to_blow = false
		if target == null:
			target = get_tree().get_first_node_in_group("garbage_pile")
		if target == null: return
		var dir = (target.global_position - global_position).normalized()

		var new_emitter: GPUParticles2D = duplicate()
		new_emitter.one_shot = true
		add_sibling(new_emitter)
		new_emitter.global_position = global_position
		new_emitter.amount = amount
		new_emitter.burst_in_direction(dir)
		new_emitter.finished.connect(new_emitter.queue_free)
		new_emitter.finished.connect(on_burst_end)

func on_burst_end():
	ready_to_blow = true
