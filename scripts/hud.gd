extends CanvasLayer


func _ready() -> void:
	var items = $ItemList.find_children("*", "Node")
	for item in items:
		item.queue_free()
	Signals.pick_up.connect(add_item)

func add_item(item: Item):
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.texture = item.texture
	$ItemList.add_child(texture_rect)
