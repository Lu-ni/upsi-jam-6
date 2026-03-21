extends Node

var items: Dictionary[String, Item] = {}

func _enter_tree() -> void:
	add_item_to_list("PODS", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/icons/pods.png")
	add_item_to_list("TIME", Item.ITEM_TYPE.PRECIOUS, 300, 5, "res://assets/icons/time.png")
	add_item_to_list("VALUE", Item.ITEM_TYPE.PRECIOUS, 500, 1, "res://assets/icons/value.png")

func add_item_to_list(name, type, value, weight, texture):
	items[name] = Item.new()
	items[name].item_name = name
	items[name].item_type = type
	items[name].value = value
	items[name].weight = weight
	items[name].texture = load(texture)
