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
		menu = get_tree().root.get_node("MainMenu")
	if Input.is_action_just_pressed("ui_cancel") and in_game:
		end_game()

func _ready() -> void:
	pass

func toggle_pause_menu():
	pass

func start_game():
	reset_game_data()
	world = load("res://scenes/World.tscn").instantiate()
	add_sibling(world)
	hud.visible = true
	menu.visible = false
	in_game = true

func end_game():
	world.queue_free()
	hud.visible = false
	menu.visible = true
	in_game = false

func reset_game_data():
	GameInfo.throw_trash_time = BaseDataValues.base_throw_trash_time
	GameInfo.amount_of_trash_collected = BaseDataValues.base_amount_of_trash_collected
	GameInfo.has_seen_craft_tuto = false
	GameInfo.has_seen_shop_tuto = false
	GameInfo.time_used = 0
	PlayerInfo.inventory = []
	PlayerInfo.max_inventory = BaseDataValues.base_max_inventory
	Signals.inventory_updated.emit()
