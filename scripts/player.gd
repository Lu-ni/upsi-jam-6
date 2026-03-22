extends CharacterBody2D

@export var speed: float = 200.0
@export var squish_frequency: float = 8.0
@export var squish_amount: float = 0.005

var last_direction: Vector2 = Vector2.DOWN
var bob_time: float = false

func _ready() -> void:
	PlayerManager.player = self
	Signals.stat_upgraded.connect(_on_stat_upgraded)
	PlayerManager.biome_in.connect(_toggle_swimming)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.SPEED:
			speed += amount
			print("New speed: ", speed, "(+", amount,  ")")

var is_swimming : bool = false
func _toggle_swimming(biome : String):
	if biome == "ocean":
		is_swimming = true
	else:
		is_swimming = false

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_O:
			PlayerInfo.field_of_view -= 1
		if event.keycode == KEY_P:
			PlayerInfo.field_of_view += 1

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO and not is_swimming:
		direction = direction.normalized()
		last_direction = direction
		play_animation("walk", direction)
		bob_time += delta * squish_frequency
		var squish = abs(sin(bob_time)) * squish_amount
		$AnimatedSprite2D.scale.y = 0.1 - squish
	elif direction != Vector2.ZERO and is_swimming:
		direction = direction.normalized()
		last_direction = direction
		play_animation("swim", direction)
		bob_time += delta * squish_frequency
		var squish = abs(sin(bob_time)) * squish_amount
		$AnimatedSprite2D.scale.y = 0.1 - 2 * squish
	elif not is_swimming:
		play_animation("idle", last_direction)
		bob_time += delta * squish_frequency
		var squish = abs(sin(bob_time)) * squish_amount
		$AnimatedSprite2D.scale.y = 0.1 - squish/3
		#$AnimatedSprite2D.scale.y = lerp($AnimatedSprite2D.scale.y, 0.1, 0.08)

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
