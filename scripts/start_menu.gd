extends Control
#@onready var start_lever = preload("res://scenes/MainScene.tscn");
@onready var option_menu = preload("res://scenes/OptionsMenu.tscn");


func _on_start_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn");

func _on_leaderboard_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/LeaderBoard.tscn");

func _on_option_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn");

func _on_exit_btn_button_down() -> void:
	get_tree().quit()
