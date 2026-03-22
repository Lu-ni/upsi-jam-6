extends Node

var items: Dictionary[String, Item] = {}
func _enter_tree() -> void:
	# Consumable
	add_item_to_list("apple", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/apple.svg")
	add_item_to_list("banana", Item.ITEM_TYPE.PRECIOUS, 300, 5, "res://assets/sprites/items-and-more/banana-peal.svg")
	add_item_to_list("bottle", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/bottle.svg")
	add_item_to_list("chicken", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/chicken-meat.svg")
	add_item_to_list("cotton-candy", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/cotton-candy.svg")
	add_item_to_list("hamburgers", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/hamburger.svg")
	add_item_to_list("toast", Item.ITEM_TYPE.COSUMABLE, 500, 1, "res://assets/sprites/items-and-more/toast.svg")
	#electronics
	add_item_to_list("toaster", Item.ITEM_TYPE.ELECTRONICS, 500, 1, "res://assets/sprites/items-and-more/toater.svg")
	add_item_to_list("gameboy", Item.ITEM_TYPE.ELECTRONICS, 500, 1, "res://assets/sprites/items-and-more/gameboy.svg")


func add_item_to_list(name, type, value, weight, texture):
	items[name] = Item.new()
	items[name].item_name = name
	items[name].item_type = type
	items[name].value = value
	items[name].weight = weight
	items[name].texture = load(texture)
"res://assets/sprites/items-and-more/chicken-meat.svg"
"res://assets/sprites/items-and-more/cotton-candy.svg"
"res://assets/sprites/items-and-more/gameboy.svg"
"res://assets/sprites/items-and-more/hamburger.svg"
"res://assets/sprites/items-and-more/toast.svg"
"res://assets/sprites/items-and-more/toater.svg"
