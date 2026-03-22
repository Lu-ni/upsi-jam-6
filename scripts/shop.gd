extends StaticBody2D

const SHOP_CARD_SCENE = preload("res://scenes/shop_menu.tscn")
var card_instances: Array = []
const CARD_SPACING = 220

const SHOP_SLOTS_COUNT = 3
const ALLOW_DUPLICATES = false
var shop_slots_indices: Array[int] = []

@export var use_global_reroll_price: bool = false
@export var use_precious_for_reroll: bool = false

var reroll_price: int = 10
var all_deals: Array[Deal] = []
var reroll_count: int = 0

var is_tutorial_playing: bool = false
var waiting_player_body = null

const RARITY_CHANCES = {
	PlayerInfo.Rarity.COMMON: 60,   # X%
	PlayerInfo.Rarity.UNCOMMON: 25,
	PlayerInfo.Rarity.RARE: 12,
	PlayerInfo.Rarity.EPIC: 100
}


func _ready() -> void:
	var vis = VisibleOnScreenNotifier2D.new()
	add_child(vis)
	vis.screen_entered.connect(_on_screen_entered)

	# Initialisation des deals : (Nom, Desc, Icon_Path, PriceDict, randomPrice, RewardID)
	all_deals.append(Deal.new("Speed Up", "Augmente la vitesse", "res://assets/test/Yellow.png", {"PRECIOUS": 2}, false, "speed"))
	all_deals.append(Deal.new("Pickup Range", "Augmente la range de ramassage", "res://assets/test/Green.png", {"PRECIOUS": 2}, false, "pickup_range"))
	all_deals.append(Deal.new("Drop Speed", "Augmente la vitesse de drop", "res://assets/test/White.png", {"PRECIOUS": 2}, false, "drop_speed"))
	all_deals.append(Deal.new("Dump Cooldown", "Reduit le cooldown de dump", "res://assets/test/Red.png", {"PRECIOUS": 2}, false, "dump_cooldown"))
	$ShopPart.play("default")
	reroll_shop()

func reroll_shop() -> void:
	shop_slots_indices.clear()
	for i in range(SHOP_SLOTS_COUNT):
		shop_slots_indices.append(get_random_item_index())

func get_random_item_index() -> int:
	var potential_indices = range(all_deals.size())

	if not ALLOW_DUPLICATES:
		for idx in shop_slots_indices:
			potential_indices.erase(idx)

	if potential_indices.is_empty():
		return randi() % all_deals.size()

	return potential_indices.pick_random()

func replace_item_at_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return

	var current_indices_copy = shop_slots_indices.duplicate()
	current_indices_copy.remove_at(slot_index)

	var potential_indices = range(all_deals.size())

	if not ALLOW_DUPLICATES:
		for idx in current_indices_copy:
			potential_indices.erase(idx)

	if potential_indices.is_empty():
		shop_slots_indices[slot_index] = randi() % all_deals.size()
	else:
		shop_slots_indices[slot_index] = potential_indices.pick_random()

func get_item_at_slot(slot_index: int) -> Deal:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return null
	return all_deals[shop_slots_indices[slot_index]]

func update_item_price_at_slot(slot_index: int, new_price: Dictionary) -> void:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return
	all_deals[shop_slots_indices[slot_index]].current_price = new_price

func can_player_afford(deal: Deal) -> bool:
	for price_item_name in deal.current_price.keys():
		var required_amount = deal.current_price[price_item_name]
		var player_has = 0
		for inv_item in PlayerInfo.inventory:
			if price_item_name == "PRECIOUS":
				if inv_item.item_type == Item.ITEM_TYPE.PRECIOUS:
					player_has += 1
			else:
				if inv_item.item_name == price_item_name:
					player_has += 1
		if player_has < required_amount:
			return false
	return true

func pay_for_deal(deal: Deal) -> void:
	if (ShopManager.DEBUG == true):
		print("Mode Debug activé !")
		return
	for price_item_name in deal.current_price.keys():
		var required_amount = deal.current_price[price_item_name]
		for i in range(required_amount):
			for j in range(PlayerInfo.inventory.size()):
				if price_item_name == "PRECIOUS":
					if PlayerInfo.inventory[j].item_type == Item.ITEM_TYPE.PRECIOUS:
						PlayerInfo.inventory.remove_at(j)
						break
				else:
					if PlayerInfo.inventory[j].item_name == price_item_name:
						PlayerInfo.inventory.remove_at(j)
						break
	Signals.inventory_updated.emit()


func get_random_rarity() -> int:
	var roll = randi() % 100
	var cumulative = 0

	for rarity in RARITY_CHANCES.keys():
		cumulative += RARITY_CHANCES[rarity]
		if roll < cumulative:
			return rarity

	return PlayerInfo.Rarity.COMMON # Fallback

#func _on_screen_entered() -> void:
#	if not GameInfo.has_seen_shop_tuto:
#		GameInfo.has_seen_shop_tuto = true
#		is_tutorial_playing = true
#		var popup = load("res://scenes/tuto_popup.tscn").instantiate()
#		add_child(popup)
#
#		# On place toujours le tuto de shop AU-DESSUS (y = -65)
#		popup.position = Vector2(-120, -65)
#
#		# Connect to signal before starting
#		popup.tutorial_finished.connect(func():
#			is_tutorial_playing = false
#			if waiting_player_body != null:
#				_on_area_2d_body_entered(waiting_player_body)
#				waiting_player_body = null
#		)
#
#		if popup.has_method("start_tutorial"):
#			popup.start_tutorial("Here you can buy items to get stronger!")

func grant_reward(reward_id: String) -> void:
	var rarity = get_random_rarity()
	print("rarity = ", rarity)
	match reward_id:
		"speed":
			Signals.upgrade_stat.emit(PlayerInfo.Stat.SPEED, rarity)
		"pickup_range":
			Signals.upgrade_stat.emit(PlayerInfo.Stat.PICKUP_RANGE, rarity)
		"drop_speed":
			Signals.upgrade_stat.emit(PlayerInfo.Stat.DROP_SPEED, rarity)
		"dump_cooldown":
			Signals.upgrade_stat.emit(PlayerInfo.Stat.DUMP_COOLDOWN, rarity)
		_:
			print("Reward Action: Unknown reward_id ", reward_id)
	Signals.inventory_updated.emit()

func get_current_reroll_price() -> int:
	if use_global_reroll_price:
		return ShopManager.global_reroll_price
	return reroll_price

func update_reroll_price(new_price: int) -> void:
	if use_global_reroll_price:
		ShopManager.global_reroll_price = new_price
	else:
		reroll_price = new_price

func get_total_precious() -> int:
	var total = 0
	for inv_item in PlayerInfo.inventory:
		if inv_item.item_type == Item.ITEM_TYPE.PRECIOUS:
			total += 1
	return total

func can_player_afford_reroll() -> bool:
	if use_precious_for_reroll:
		return get_total_precious() >= get_current_reroll_price()
	return PlayerInfo.kamas >= get_current_reroll_price()

func pay_for_reroll() -> void:
	var cost = get_current_reroll_price()
	if use_precious_for_reroll:
		for i in range(cost):
			for j in range(PlayerInfo.inventory.size()):
				if PlayerInfo.inventory[j].item_type == Item.ITEM_TYPE.PRECIOUS:
					PlayerInfo.inventory.remove_at(j)
					break
		Signals.inventory_updated.emit()
	else:
		PlayerInfo.kamas -= cost

func _on_screen_entered() -> void:
	if not GameInfo.has_seen_craft_tuto:
		GameInfo.has_seen_craft_tuto = true
		is_tutorial_playing = true
		var popup = load("res://scenes/tuto_popup.tscn").instantiate()
		add_child(popup)
		popup.position = Vector2(-120, 25)
		popup.tutorial_finished.connect(func():
			is_tutorial_playing = false
			if waiting_player_body != null:
				_on_area_2d_body_entered(waiting_player_body)
				waiting_player_body = null
		)
		if popup.has_method("start_tutorial"):
			popup.start_tutorial("Here you can craft items that will be useful to you.")

func _on_area_2d_body_entered(body) -> void:
	if body.has_method("player_shop_method"):
		if is_tutorial_playing:
			waiting_player_body = body
			return
		if card_instances.is_empty():
			var canvas = CanvasLayer.new()
			canvas.name = "ShopCanvas"
			get_tree().root.add_child(canvas)

			var viewport_size = get_viewport().get_visible_rect().size
			var center_x = viewport_size.x / 2.0
			var center_y = viewport_size.y * 0.99

			for i in range(SHOP_SLOTS_COUNT):
				var card = SHOP_CARD_SCENE.instantiate()
				card.shop_owner = self
				card.slot_index = i
				card.is_craft = true
				card.position = Vector2(center_x + (i - 1) * CARD_SPACING, center_y)
				card.scale = Vector2(1.2, 1.2)
				canvas.add_child(card)
				card_instances.append(card)
	$ShopPart.play("open")

func _on_area_2d_body_exited(body) -> void:
	if body.has_method("player_shop_method"):
		if waiting_player_body == body:
			waiting_player_body = null
		for card in card_instances:
			card.queue_free()
		card_instances.clear()
		var canvas = get_tree().root.get_node_or_null("ShopCanvas")
		if canvas:
			canvas.queue_free()
	$ShopPart.play("default")
