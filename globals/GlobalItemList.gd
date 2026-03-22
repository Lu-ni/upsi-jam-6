extends Node

var items: Dictionary[String, Item] = {}
func _enter_tree() -> void:
	add_item_to_list("cheese", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 67.svg")
	add_item_to_list("axe", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 68.svg")
	add_item_to_list("porcorn", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 69.svg")
	add_item_to_list("remote", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 70.svg")
	add_item_to_list("multiprise", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 71.svg")
	add_item_to_list("cone", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 72.svg")
	add_item_to_list("crone", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 73.svg")
	add_item_to_list("weed", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 74.svg")
	add_item_to_list("knife", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 75.svg")
	add_item_to_list("diamond", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 76.svg")
	add_item_to_list("dollars", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 78.svg")
	add_item_to_list("coins", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 79.svg")
	add_item_to_list("goldenchain", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 80.svg")
	add_item_to_list("goldenpoop", Item.ITEM_TYPE.PRECIOUS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 81.svg")
	add_item_to_list("toaster", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 82.svg")
	add_item_to_list("cotton-candy", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 83.svg")
	add_item_to_list("hamburger", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 84.svg")
	add_item_to_list("chicken", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 85.svg")
	add_item_to_list("toast", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 86.svg")
	add_item_to_list("gameboy", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 87.svg")
	add_item_to_list("apple", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 88.svg")
	add_item_to_list("bottle", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 89.svg")
	add_item_to_list("banana", Item.ITEM_TYPE.COSUMABLE, 100, 2, "res://assets/sprites/items-and-more/new/Asset 90.svg")
	add_item_to_list("tv", Item.ITEM_TYPE.ELECTRONICS, 100, 2, "res://assets/sprites/items-and-more/new/Asset 91.svg")




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
