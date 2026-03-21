extends CharacterBody2D

var target: Node2D
@export var pickup_range: int
@export var move_speed: int
@export var sprite: Sprite2D
var entered_range: bool = false
var picked_up: bool = false

#var drop_type: Structure.DROP_TYPE = Skibidi

var value: int = 0

func _ready() -> void:
	get_player()
	set_sprite()

func _physics_process(delta: float) -> void:
	if picked_up:
		return
	if target == null:
		velocity = Vector2.ZERO
		get_player()
		return
	var to_target := target.global_position - global_position
	var dist := to_target.length()
	
	if entered_range or dist <= pickup_range:
		entered_range = true
		var direction := to_target.normalized()
		var proximity: float = clamp(1.0 - (dist / pickup_range), 0.0, 1.0)
		var speed_mult := 1.0 + pow(proximity, 2.0) * 6.0
		var desired_velocity := direction * move_speed * speed_mult
		velocity = velocity.lerp(desired_velocity, 8.0 * delta)
		if dist <= 50:
			picked_up = true
			sprite.visible = false
			give_player_loot()
	move_and_slide()

func get_player():
	target = get_tree().get_first_node_in_group("player")

func set_sprite():
	#if drop_type == DROP_TYPE.GOLD:
		 #sprite.texture = ResourceList.gold_sprites[0]
		pass

func give_player_loot():
	print("Woohoo yioppieeei didee dooo da you got loota ma masn")
	queue_free()
