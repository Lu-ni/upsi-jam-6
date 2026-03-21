extends CanvasLayer

func _ready() -> void:
	Signals.pick_up.connect(SKABALADAN)
	

func SKABALADAN():
	$Sprite2D.scale += Vector2(1,1)
