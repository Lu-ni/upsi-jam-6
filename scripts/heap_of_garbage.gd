extends Node2D

@export var pickup_range: int = 250
@export var cooldown: float = 500.0

var timer: int = GameInfo.throw_trash_time

var player: Node2D
var bin_pos: Node2D
var trash: Array[Sprite2D] = []
var start_frame = 3
var max_frame = 15

func _ready() -> void:
	Signals.trash_added.connect(update_bin)
	Signals.trash_removed.connect(update_bin)
	Signals.stat_upgraded.connect(_on_stat_upgraded)
	Signals.MULT_UP.connect(mult_up_display)
	update_bin(true)


func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.DUMP_RANGE:
			pickup_range += int(amount)
			print("New pickup range: ", pickup_range, "(+", amount,  ")")
		PlayerInfo.Stat.DUMP_COOLDOWN:
			cooldown = max(cooldown - int(amount), 100)
			print("New dump cooldown: ", cooldown, "(-", amount,  ")")

func _process(delta: float) -> void:
	queue_redraw()
	timer -= delta * 1000
	if player == null:
		get_player()
		return
	if timer <= 0:
		if is_in_range():
			remove_player_loot()
			timer = GameInfo.throw_trash_time

func is_in_range() -> bool:
	var to_target := player.global_position - global_position
	var dist := to_target.length()
	return dist <= pickup_range

func get_player():
	player = get_tree().get_first_node_in_group("player")

func remove_player_loot():
	if player == null or PlayerInfo.inventory.size() <= 0:
		return

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = PlayerInfo.inventory[0].texture
	Signals.gain_score.emit(PlayerInfo.inventory[0].value * GameInfo.multiplier)
	GameInfo.score += PlayerInfo.inventory[0].value * GameInfo.multiplier
	sprite.scale = Vector2.ONE * 0.4

	get_parent().add_child(sprite)

	Signals.throw.emit(PlayerInfo.inventory[0])

	sprite.global_position = player.global_position

	trash.insert(0, sprite)

	var tween := create_tween()

	tween.tween_property(
		sprite,
		"global_position",
		global_position,
		(cooldown/1000)
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# spin while moving
	tween.parallel().tween_property(
		sprite,
		"scale",
		Vector2(1.5,1.5), # two full spins
		(cooldown/1000) * 0.4
	)
	tween.parallel().tween_property(
		sprite,
		"rotation_degrees",
		randi() % 240 - 120, # two full spins
		(cooldown/1000)
	)
	tween.parallel().tween_property(
		sprite,
		"scale",
		Vector2(0.5,0.5), # two full spins
		(cooldown/1000)*0.6
	).set_delay((cooldown/1000)*0.4)

	tween.tween_callback(on_trash_land)

func on_trash_land():
	GameInfo.amount_of_trash_collected += 1
	Signals.trash_added.emit()
	trash[0].queue_free()

func update_bin(start: bool = false):
	var s: Sprite2D = $Sprite2D
	var frame_nb: int = start_frame + int(
	sqrt(GameInfo.amount_of_trash_collected / float(GameInfo.HOWMUCHTRASHFORMULTUP))
	)
	var target_frame: int = frame_nb if frame_nb <= max_frame else max_frame

	# Only shake + change frame if the frame actually changes
	if target_frame == s.frame:
		return
	if not start:
		Manager.hud.bin_frame.emit(target_frame)
		GameInfo.multiplier += 1
		if GameInfo.multiplier >= 15: GameInfo.multiplier = 14
		Signals.MULT_UP.emit()

	var tween := create_tween()
	var origin := s.position

	# Shake: alternate left/right offsets
	tween.tween_property(s, "position", origin + Vector2(10, 4), 0.05)
	tween.tween_property(s, "position", origin + Vector2(-10, -4), 0.05)
	tween.tween_property(s, "position", origin + Vector2(12, -7), 0.04)
	tween.tween_property(s, "position", origin + Vector2(-12, 7), 0.04)
	tween.tween_property(s, "position", origin, 0.03)

	# Change the frame once the shake finishes
	tween.tween_callback(func(): s.frame = target_frame)

func mult_up_display():
	if GameInfo.multiplier <= 1: return
	var container = Node2D.new()
	add_child(container)

	# Label
	var label = Label.new()
	label.text = "x" + str(GameInfo.multiplier)
	label.add_theme_font_size_override(
	"font_size",
	20 + GameInfo.multiplier * 10)
	var yellow = Color(1.0, 0.95, 0.6)
	var red = Color(1.0, 0.15, 0.1, 0.1)
	var t = clamp(GameInfo.multiplier / 14.0, 0.0, 1.0)
	label.modulate = yellow.lerp(red, t)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	container.add_child(label)

	# Celebration particles
	var particles = CPUParticles2D.new()
	particles.amount = 5 + GameInfo.multiplier * 10
	particles.lifetime = 1.5
	particles.one_shot = true
	particles.emitting = true
	particles.spread = 180
	particles.initial_velocity_min = 40 * GameInfo.multiplier
	particles.initial_velocity_max = 120 * GameInfo.multiplier
	particles.scale_amount_min = 1
	particles.scale_amount_max = 2.1
	particles.gravity = Vector2.ZERO

	container.add_child(particles)

	# Hover animation
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(container, "position:y", container.position.y - (40 + GameInfo.multiplier * 10), 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(label, "modulate:a", 0.0, 1.2)
	tween.parallel().tween_property(label, "rotation", deg_to_rad(randi() % 20 - 10), 0.6)

	tween.chain().tween_callback(container.queue_free)
