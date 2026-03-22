extends Node

var in_game: bool = false
var hud: Node = null
var menu: Node = null
var world: Node = null
var pause_menu: Node = null

var initialized: bool = false

func _process(delta: float) -> void:
	if not initialized:
		hud = load("res://scenes/HUD.tscn").instantiate()
		hud.visible = false
		get_tree().root.add_child(hud)
		initialized = true

func _ready() -> void:
	pass

func toggle_pause_menu():
	pass

func start_game():
	pass

func reset_game_data():
	pass
