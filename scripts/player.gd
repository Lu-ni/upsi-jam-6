extends CharacterBody2D

@export var speed: float = 200.0

var last_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = direction.normalized()
	velocity = direction * speed

	# if direction != Vector2.ZERO:
	# 	last_direction = direction
	# 	play_animation("walk", direction)
	# else:
	# 	play_animation("idle", last_direction)

	move_and_slide()

func play_animation(anim_type: String, direction: Vector2) -> void:
	var anim_dir: String
	var flip: bool = false

	if abs(direction.x) >= abs(direction.y):
		anim_dir = "side"
		flip = direction.x < 0
	elif direction.y < 0:
		anim_dir = "up"
	else:
		anim_dir = "down"

	$AnimatedSprite2D.flip_h = flip
	$AnimatedSprite2D.play(anim_type + "_" + anim_dir)
