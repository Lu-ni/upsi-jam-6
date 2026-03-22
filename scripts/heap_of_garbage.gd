extends Node2D

@export var pickup_range: int

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
	update_bin()

func _draw() -> void:
	draw_circle(Vector2.ZERO, pickup_range, Color.CORNFLOWER_BLUE, false, 5)

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
		0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# spin while moving
	tween.parallel().tween_property(
		sprite,
		"scale",
		Vector2(1.5,1.5), # two full spins
		0.2
	)
	tween.parallel().tween_property(
		sprite,
		"rotation_degrees",
		randi() % 240 - 120, # two full spins
		0.5
	)
	tween.parallel().tween_property(
		sprite,
		"scale",
		Vector2(0.5,0.5), # two full spins
		0.3
	).set_delay(0.25)

	tween.tween_callback(on_trash_land)

func on_trash_land():
	GameInfo.amount_of_trash_collected += 1
	Signals.trash_added.emit()
	trash[0].queue_free()

func update_bin():
	var s: Sprite2D = $Sprite2D
	var frame_nb: int = start_frame + (GameInfo.amount_of_trash_collected / amount_trash_for_next_bin_frame)
	s.frame = frame_nb if frame_nb <= max_frame else max_frame
