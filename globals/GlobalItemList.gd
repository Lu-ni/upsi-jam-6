extends Node

var example_item: Item

func _enter_tree() -> void:
	example_item = Item.new()
	example_item.item_type = Item.ITEM_TYPE.thingy
	example_item.valeur_en_kamas = 500
	example_item.pods = 2
	example_item.texture = load("res://icon.svg")
