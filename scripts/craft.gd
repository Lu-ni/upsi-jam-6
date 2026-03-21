extends StaticBody2D

const SHOP_MENU_SCENE = preload("res://scenes/shop_menu.tscn")
var menu_instance = null

const SHOP_SLOTS_COUNT = 3
const ALLOW_DUPLICATES = false
var shop_slots_indices: Array[int] = []

# reroll price global or not (instancier par shop)
@export var use_global_reroll_price: bool = false

var reroll_price: int = 10
var all_deals: Array[Deal] = []

var reroll_count: int = 0

func _ready() -> void:
	# Initialisation des deals : (Nom, Desc, Icon_Path, PriceDict, randomPrice, RewardID)
	all_deals.append(Deal.new("Waste +1", "augmente the number of recolted Waste", "res://assets/test/Red.png", {"Skabungle": 1}, false, "add_waste"))
	all_deals.append(Deal.new("Herbal +1", "augmente the number of recolted Herbal", "res://assets/test/Green.png", {"Babakiki": 1}, false, "add_herbal"))
	all_deals.append(Deal.new("Electrical +1", "augmente the number of recolted Electrical", "res://assets/test/White.png", {"Kungamingu": 1}, false, "add_electrical"))
	all_deals.append(Deal.new("Move spd +1", "augmente the global move spd", "res://assets/test/Yellow.png", {"Skabungle": 5}, false, "add_move_spd"))
	all_deals.append(Deal.new("Inventory +1", "augmente Inventory slot", "res://assets/test/Black.png", {"Babakiki": 5}, false, "add_inventory"))
	
	reroll_shop()

func reroll_shop() -> void:
	shop_slots_indices.clear()
	for i in range(SHOP_SLOTS_COUNT):
		var new_index = get_random_item_index()
		shop_slots_indices.append(new_index)

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
	
	var real_index = shop_slots_indices[slot_index]
	return all_deals[real_index]

func update_item_price_at_slot(slot_index: int, new_price: Dictionary) -> void:
	if slot_index < 0 or slot_index >= shop_slots_indices.size():
		return
		
	var real_index = shop_slots_indices[slot_index]
	all_deals[real_index].current_price = new_price

func can_player_afford(deal: Deal) -> bool:
	for price_item_name in deal.current_price.keys():
		var required_amount = deal.current_price[price_item_name]
		var player_has = 0
		# Compte combien le joueur a de cet item
		for inv_item in PlayerInfo.inventory:
			if inv_item.item_name == price_item_name:
				player_has += 1
		
		if player_has < required_amount:
			return false
	return true

func pay_for_deal(deal: Deal) -> void:
	for price_item_name in deal.current_price.keys():
		var required_amount = deal.current_price[price_item_name]
		# Retire le montant requis de l'inventaire
		for i in range(required_amount):
			for j in range(PlayerInfo.inventory.size()):
				if PlayerInfo.inventory[j].item_name == price_item_name:
					PlayerInfo.inventory.remove_at(j)
					break # Sort de la boucle pour trouver le suivant
	
	# Après avoir tout retiré, on met à jour l'UI globale
	Signals.inventory_updated.emit()

func grant_reward(reward_id: String) -> void:
	match reward_id:
		"add_waste":
			print("Reward Action: Player gains +1 Waste bonus")
			# Logique concrète à lié avec le manager/player
		"add_herbal":
			print("Reward Action: Player gains +1 Herbal bonus")
		"add_electrical":
			print("Reward Action: Player gains +1 Electrical bonus")
		"add_move_spd":
			print("Reward Action: Player gains +1 Move spd")
		"add_inventory":
			print("Reward Action: Player gains +1 Inventory slot")
			GameInfo.max_inventory += 1
		_:
			print("Reward Action: Unknown reward_id ", reward_id)

func _on_area_2d_body_entered(body) -> void:
	if body.has_method("player_shop_method"):
		if menu_instance == null:
			menu_instance = SHOP_MENU_SCENE.instantiate()

			menu_instance.shop_owner = self
			add_child(menu_instance)

func _on_area_2d_body_exited(body) -> void:
	if body.has_method("player_shop_method"):
		if menu_instance != null:
			menu_instance.queue_free()
			menu_instance = null

func get_current_reroll_price() -> int:
	if use_global_reroll_price:
		return ShopManager.global_reroll_price
	else:
		return reroll_price

func update_reroll_price(new_price: int) -> void:
	if use_global_reroll_price:
		ShopManager.global_reroll_price = new_price
	else:
		reroll_price = new_price
