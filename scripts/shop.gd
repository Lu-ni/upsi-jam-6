extends StaticBody2D

const SHOP_MENU_SCENE = preload("res://scenes/shop_menu.tscn")
var menu_instance = null

const SHOP_SLOTS_COUNT = 3
const ALLOW_DUPLICATES = false
var shop_slots_indices: Array[int] = []

# reroll price global or not (instancier par shop)
@export var use_global_reroll_price: bool = false

var reroll_price: int = 10
var items = [
	{"icon": "res://assets/test/Red.png", "name": "Waste +1", "price": 1, "desc": "augmente the number of recolted Waste", "count": 0},
	{"icon": "res://assets/test/Green.png", "name": "Herbal +1", "price": 1, "desc": "augmente the number of recolted Herbal", "count": 0},
	{"icon": "res://assets/test/White.png", "name": "Electrical +1", "price": 1, "desc": "augmente the number of recolted Electrical", "count": 0},
	{"icon": "res://assets/test/Yellow.png", "name": "move spd +1", "price": 5, "desc": "augmente the global move spd", "count": 0},
	{"icon": "res://assets/test/Black.png", "name": "move Inventory +1", "price": 5, "desc": "augmente Inventory slot", "count": 0}
]

var reroll_count: int = 0

func _ready() -> void:
	reroll_shop()

func reroll_shop() -> void:
	shop_slots_indices.clear()
	for i in range(SHOP_SLOTS_COUNT):
		var new_index = get_random_item_index()
		shop_slots_indices.append(new_index)

func get_random_item_index() -> int:
	var potential_indices = range(items.size())

	if not ALLOW_DUPLICATES:
		for idx in shop_slots_indices:
			potential_indices.erase(idx)

	if potential_indices.is_empty():
		return randi() % items.size()

	return potential_indices.pick_random()

func replace_item_at_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return

	var current_indices_copy = shop_slots_indices.duplicate()
	current_indices_copy.remove_at(slot_index)

	var potential_indices = range(items.size())

	if not ALLOW_DUPLICATES:
		for idx in current_indices_copy:
			potential_indices.erase(idx)

	if potential_indices.is_empty():
		shop_slots_indices[slot_index] = randi() % items.size()
	else:
		shop_slots_indices[slot_index] = potential_indices.pick_random()

func get_item_at_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return {}

	var real_index = shop_slots_indices[slot_index]
	return items[real_index]

func update_item_price_at_slot(slot_index: int, new_price: int) -> void:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return

	var real_index = shop_slots_indices[slot_index]
	items[real_index]["price"] = new_price

func _on_area_2d_body_entered(body) -> void:
	if body.has_method("player_shop_method"):
		if menu_instance == null:
			menu_instance = SHOP_MENU_SCENE.instantiate()

			menu_instance.shop_owner = self
			add_child(menu_instance)

func _on_area_2d_body_exited(body) -> void:
	if body.has_method("player_shop_method"):
		if menu_instance != null:
			menu_instance.queue_free()
			menu_instance = null

func get_current_reroll_price() -> int:
	if use_global_reroll_price:
		return ShopManager.global_reroll_price
	else:
		return reroll_price

func update_reroll_price(new_price: int) -> void:
	if use_global_reroll_price:
		ShopManager.global_reroll_price = new_price
	else:
		reroll_price = new_price

func update_item_price(index: int, new_price: int) -> void:
	if index >= 0 and index < items.size():
		items[index]["price"] = new_price
