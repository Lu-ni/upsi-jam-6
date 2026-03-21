extends Node

var inventory: Array[Item]
var kamas: int
#var ta_race_jsp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.pick_up.connect(add_item_to_inventory)
	Signals.throw.connect(remove_item_from_inventory)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_item_to_inventory(item: Item):
	inventory.append(item)
	
func remove_item_from_inventory(item: Item):
	for i in inventory:
		if i == item:
			inventory.erase(i)
			return
