extends Node2D

func _ready() -> void:
	$Play.pressed.connect(on_play_pressed)
	$Credits.pressed.connect(on_credits_pressed)
	$Quit.pressed.connect(on_quit_pressed)

func on_play_pressed():
	Manager.start_game()

func on_credits_pressed():
	pass

func on_quit_pressed():
	get_tree().quit()
