extends CanvasLayer

func _ready() -> void:
	var items = $ItemList.find_children("*", "Node")
	for item in items:
		item.queue_free()
	Signals.pick_up.connect(add_item)

func _process(delta: float) -> void:
	GameInfo.time_used += delta
	$Time/Label.text = format_time(GameInfo.time_used)

func add_item(item: Item):
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.texture = item.texture
	$ItemList.add_child(texture_rect)
	display_item_info()

func remove_item(item: Item):
	for i in $items.find_children("*", "Node"):
		if i == item:
			item.queue_free()
			break
	display_item_info()

func display_item_info():
	var total_weight = 0
	var total_value = 0
	for i: Item in PlayerInfo.inventory:
		total_weight += i.weight
		total_value += i.value
	$Weight/Label.text = str(total_weight)
	$Value/Label.text = str(total_value)

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds / 60)
	var seconds = int(time_seconds) % 60
	#var milliseconds = int((time_seconds - int(time_seconds)) * 1000)

	return "%02d:%02d" % [minutes, seconds]# milliseconds]
