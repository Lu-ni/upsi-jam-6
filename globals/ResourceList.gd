extends Node

# EXAMPLES (Maybe replace Node type with class later?)
var hud: Node
var menu: Node
var world: Node
var pause_menu: Node
var initialized: bool = false

func _process(delta: float) -> void:
	if not initialized:
		hud = load("res://scenes/hud.tscn").instantiate()
		get_tree().root.add_child(hud)
		initialized = true
