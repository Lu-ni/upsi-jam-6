extends CharacterBody2D
class_name Drop

var target: Node2D
@export var pickup_range: int
@export var move_speed: int
var entered_range: bool = false
var picked_up: bool = false
var item: Item = null

func _ready() -> void:
	# TEMP RAND ITEM SELECTION
	var selection = randi() % GlobalItemList.items.size()
	var keys = GlobalItemList.items.keys()
	var rand_index = randi() % keys.size()
	var key = keys[rand_index]
	item = GlobalItemList.items[key]

	$Sprite2D.scale = Vector2(0.4, 0.4)
	get_player()
	set_sprite()
	Signals.stat_upgraded.connect(_on_stat_upgraded)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.PICKUP_RANGE:
			pickup_range += int(amount)
		PlayerInfo.Stat.DROP_SPEED:
			move_speed += int(amount)

func _physics_process(delta: float) -> void:
	if picked_up:
		return
	if target == null:
		velocity = Vector2.ZERO
		get_player()
		return
	var to_target := target.global_position - global_position
	var dist := to_target.length()

	if PlayerInfo.inventory.size() >= PlayerInfo.max_inventory:
		entered_range = false
		target = null
		lerp(velocity, Vector2.ZERO, 0.1)
		return

	if entered_range or dist <= pickup_range:
		entered_range = true
		var direction := to_target.normalized()
		var proximity: float = clamp(1.0 - (dist / pickup_range), 0.0, 1.0)
		var speed_mult := 1.0 + pow(proximity, 2.0) * 6.0
		var desired_velocity := direction * move_speed * speed_mult
		velocity = velocity.lerp(desired_velocity, 8.0 * delta)
		if dist <= 50:
			picked_up = true
			$Sprite2D.visible = false
			give_player_loot()
	move_and_slide()

func get_player():
	target = get_tree().get_first_node_in_group("player")

func set_sprite():
	if item != null and item.texture != null:
		$Sprite2D.texture = item.texture

func give_player_loot():
	if PlayerInfo.inventory.size() < PlayerInfo.max_inventory:
		Signals.pick_up.emit(item)
	queue_free()
