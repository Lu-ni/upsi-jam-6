extends Node2D

func _ready() -> void:
	$Menu.pressed.connect(on_menu_press)

func on_menu_press():
	Manager.return_to_menu()

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	#var milliseconds = int((time_seconds - int(time_seconds)) * 1000)

	return "%02d:%02d" % [minutes, seconds]# milliseconds]

func update():
	$Label2.text = "Your reign lasted: " + format_time(GameInfo.total_time)
	$Label3.text = "Your final score was: " + str(GameInfo.score)
