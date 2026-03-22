extends Node2D

@export var target: Node2D

@export var max_height := 200.0
@export var influence_distance := 200.0

var base_position: Vector2
var time := 0.0

func _ready():
	base_position = position

func _process(delta):
	time += delta

	var mouse_pos = get_viewport().get_mouse_position()
	var button_pos = target.global_position

	var distance = mouse_pos.distance_to(button_pos)

	var t = clamp(1.0 - distance / influence_distance, 0.0, 1.0)

	# base lift
	var lift = max_height * t

	position.y = base_position.y - lift
