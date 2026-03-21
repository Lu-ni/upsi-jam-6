extends Node2D

@export var pickup_range: int
@export var cooldown: int = 1000

var timer: int = cooldown

var player: Node2D
var bin_pos: Node2D
var trash: Array[Sprite2D] = []

func _process(delta: float) -> void:
	timer -= delta * 1000
	if player == null:
		get_player()
		return
	if timer <= 0:
		if is_in_range():
			remove_player_loot()
			timer = cooldown

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

	trash.append(sprite)

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

	tween.tween_callback(sprite.queue_free)
