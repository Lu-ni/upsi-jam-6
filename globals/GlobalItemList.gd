extends Node

var items: Dictionary[String, Item] = {}
func _enter_tree() -> void:
	add_item_to_list("apple", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/apple.svg")
	add_item_to_list("banana", Item.ITEM_TYPE.COSUMABLE, 300, 5, "res://assets/sprites/items-and-more/banana-peal.svg")
	add_item_to_list("bottle", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/bottle.svg")
func add_item_to_list(name, type, value, weight, texture):
	items[name] = Item.new()
	items[name].item_name = name
	items[name].item_type = type
	items[name].value = value
	items[name].weight = weight
	items[name].texture = load(texture)
