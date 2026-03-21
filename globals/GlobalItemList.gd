extends Node

var example_item: Item

func _enter_tree() -> void:
	example_item = Item.new()
	example_item.item_type = Item.ITEM_TYPE.thingy
	example_item.value = 500
	example_item.weight = 2
	example_item.texture = load("res://icon.svg")
