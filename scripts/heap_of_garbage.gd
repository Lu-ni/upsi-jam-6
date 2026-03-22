extends Node2D

@export var pickup_range: int
@export var cooldown: float = 500.0

var timer: int = GameInfo.throw_trash_time

var player: Node2D
var bin_pos: Node2D
var trash: Array[Sprite2D] = []
var amount_trash_for_next_bin_frame = 1
var start_frame = 3
var max_frame = 15

func _ready() -> void:
	Signals.trash_added.connect(update_bin)
	Signals.trash_removed.connect(update_bin)
	Signals.stat_upgraded.connect(_on_stat_upgraded)
	update_bin()

func _draw() -> void:
	draw_circle(Vector2.ZERO, pickup_range, Color.CORNFLOWER_BLUE, false, 5)

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
	GameInfo.score += int(PlayerInfo.inventory[0].value * PlayerInfo.score_multiplier)
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

func update_bin():
	var s: Sprite2D = $Sprite2D
	var frame_nb: int = start_frame + (GameInfo.amount_of_trash_collected / amount_trash_for_next_bin_frame)
	var target_frame: int = frame_nb if frame_nb <= max_frame else max_frame

	# Only shake + change frame if the frame actually changes
	if target_frame == s.frame:
		return

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
	if Manager.hud:
		Manager.hud.bin_frame.emit(target_frame)
