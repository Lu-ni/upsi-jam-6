extends CanvasLayer

func _ready() -> void:
	clear_inventory_display()
	Signals.pick_up.connect(on_pickup)

func _process(delta: float) -> void:
	GameInfo.time_used += delta
	$Time/Label.text = format_time(GameInfo.time_used)

func add_item(item: Item, count: int):
	var hud_item = load("res://scenes/hud_item.tscn").instantiate()
	hud_item.texture = item.texture
	hud_item.stretch_mode = TextureRect.STRETCH_KEEP
	hud_item.get_node("Label").text = str(count) if count != 1 else ""
	$ItemList.add_child(hud_item)

func clear_inventory_display():
	var items = $ItemList.find_children("*", "Node", false, false)
	for item in items:
		print("Ciaoa")
		item.queue_free()

#func remove_item(item: Item):
	#for i in $items.find_children("*", "Node"):
		#if i == item:
			#item.queue_free()
			#break
	#display_item_info()

func display_inventory():
	var stacks := {}  # Dictionary to hold counts

	for item in PlayerInfo.inventory:
		if stacks.has(item.item_name):
			stacks[item.item_name] += 1
		else:
			stacks[item.item_name] = 1

	# Convert to an array of dictionaries for sorting/display
	for key in stacks.keys():
		print("Displaying stack of %d %ss" % [stacks[key], key])
		add_item(GlobalItemList.items[key], stacks[key])

func display_item_info():
	$Weight/Label.text = ("%d/%d" % [PlayerInfo.inventory.size(), GameInfo.max_inventory])
	$Weight/Label.modulate = Color.RED if PlayerInfo.inventory.size() >= GameInfo.max_inventory else Color.WHITE

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	#var milliseconds = int((time_seconds - int(time_seconds)) * 1000)

	return "%02d:%02d" % [minutes, seconds]# milliseconds]

func on_pickup(item):
	clear_inventory_display()
	display_inventory()
	display_item_info()
