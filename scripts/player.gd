extends CharacterBody2D

@export var speed: float = 200.0
@export var squish_frequency: float = 8.0
@export var squish_amount: float = 0.005

var last_direction: Vector2 = Vector2.DOWN
var bob_time: float = 0.0

func _ready() -> void:
	PlayerManager.player = self
	Signals.stat_upgraded.connect(_on_stat_upgraded)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.SPEED:
			speed += amount

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		last_direction = direction
		play_animation("walk", direction)
		bob_time += delta * squish_frequency
		var squish = abs(sin(bob_time)) * squish_amount
		$AnimatedSprite2D.scale.y = 0.1 - squish
	else:
		#play_animation("idle", last_direction)
		bob_time = 0.0
		$AnimatedSprite2D.scale.y = lerp($AnimatedSprite2D.scale.y, 0.1, 0.08)

	velocity = direction * speed
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

func player_shop_method() -> void:
	pass

func player_craft_method() -> void:
	pass
