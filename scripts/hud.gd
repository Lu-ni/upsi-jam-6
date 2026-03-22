extends CanvasLayer

signal bin_frame(int)

func _ready() -> void:
	clear_inventory_display()
	Signals.pick_up.connect(on_item_change)
	Signals.throw.connect(on_item_change)
	Signals.inventory_updated.connect(on_inventory_change)
	bin_frame.connect(display_bin_frame)

func _process(delta: float) -> void:
	if not Manager.in_game: return
	GameInfo.time_left -= delta
	GameInfo.total_time += delta
	if GameInfo.time_left <= 0:
		Manager.go_to_end_menu()
		pass
	$Time/Label.text = format_time(GameInfo.time_left)

func add_item(item: Item, count: int):
	var hud_item = load("res://scenes/hud_item.tscn").instantiate()
	hud_item.texture = item.texture
	hud_item.stretch_mode = TextureRect.STRETCH_KEEP
	hud_item.get_node("Label").text = str(count) if count != 1 else ""
	$ItemList.add_child(hud_item)

func clear_inventory_display():
	var items = $ItemList.find_children("*", "Node", false, false)
	for item in items:
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
		add_item(GlobalItemList.items[key], stacks[key])

func display_bin_frame(frame: int):
	$Value.frame = frame

func display_item_info():
	$Weight/Label.text = ("%d/%d" % [PlayerInfo.inventory.size(), PlayerInfo.max_inventory])
	$Weight/Label.modulate = Color.RED if PlayerInfo.inventory.size() >= PlayerInfo.max_inventory else Color.WHITE
	$Value/Label.text = str(GameInfo.score)

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	#var milliseconds = int((time_seconds - int(time_seconds)) * 1000)

	return "%02d:%02d" % [minutes, seconds]# milliseconds]

func on_item_change(item):
	clear_inventory_display()
	display_inventory()
	display_item_info()

func on_inventory_change():
	clear_inventory_display()
	display_inventory()
	display_item_info()
