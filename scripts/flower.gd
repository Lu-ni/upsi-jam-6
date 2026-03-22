extends Sprite2D

@export var sway_strength := 10.0     # max rotation in degrees
@export var sway_speed := 1.5         # wind speed
@export var sway_offset := 3.0        # slight sideways movement

var time := 0.0
var base_position: Vector2

func _ready():
	base_position = position

func _process(delta):
	time += delta
	
	# Smooth wind sway
	var sway = sin(time * sway_speed)
	
	# Rotate like a bending flower
	rotation_degrees = sway * sway_strength
	
	# Slight sideways movement
	position.x = base_position.x + sway * sway_offset
