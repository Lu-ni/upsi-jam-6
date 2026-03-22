extends CanvasLayer

signal bin_frame(int)

func _ready() -> void:
	clear_inventory_display()
	Signals.pick_up.connect(on_item_change)
	Signals.throw.connect(on_item_change)
	Signals.inventory_updated.connect(on_inventory_change)
	Signals.MULT_UP.connect(on_inventory_change)
	Signals.gain_score.connect(gain_score)
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
	var yellow = Color(1.0, 0.95, 0.6)
	var red = Color(1.0, 0.15, 0.1)
	var t = clamp(GameInfo.multiplier / 14.0, 0.0, 1.0)
	$Value/mult.modulate = yellow.lerp(red, t)
	$Value/mult.text = "x" + str(GameInfo.multiplier)

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

func gain_score(score: int):
	var label := Label.new()
	add_child(label)

	# Text
	label.text = "+" + str(score)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Appearance
	label.add_theme_font_size_override("font_size", 28)
	var yellow = Color(1.0, 0.95, 0.6)
	var red = Color(1.0, 0.15, 0.1)
	var t = clamp(GameInfo.multiplier / 14.0, 0.0, 1.0)
	label.modulate = yellow.lerp(red, t)

	# Start position
	label.global_position = $Value/Node2D.global_position

	# Tween animation
	var tween := create_tween()
	tween.set_parallel(true)

	# Float upward
	tween.tween_property(label, "position:y", label.position.y - 40, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# Fade out
	tween.tween_property(label, "modulate:a", 0.0, 1.2)

	# Delete when finished
	tween.chain().tween_callback(label.queue_free)
