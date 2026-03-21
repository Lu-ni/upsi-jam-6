class_name Deal
extends RefCounted

var item_name: String
var desc: String
var texture_path: String
var base_price: Dictionary = {}
var current_price: Dictionary = {}
var randomize_price: bool = false
var count: int = 0
var reward_id: String

func _init(p_name: String, p_desc: String, p_icon: String, p_price: Dictionary, p_randomize: bool, p_reward_id: String) -> void:
	self.item_name = p_name
	self.desc = p_desc
	self.texture_path = p_icon
	self.randomize_price = p_randomize
	self.reward_id = p_reward_id
	
	if self.randomize_price:
		self.base_price = generate_random_price(p_name)
	else:
		self.base_price = p_price.duplicate()
		
	self.current_price = self.base_price.duplicate()

func generate_random_price(seed_string: String) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_string.hash() 
	
	var possible_items = GlobalItemList.items.keys()
	var new_price = {}
	
	if possible_items.size() > 0:
		var nb_currencies = rng.randi_range(1, min(2, possible_items.size()))
		var used_indices = []
		
		for i in range(nb_currencies):
			var idx = rng.randi() % possible_items.size()
			while idx in used_indices:
				idx = (idx + 1) % possible_items.size()
			used_indices.append(idx)
			
			var currency_name = possible_items[idx]
			var amount = rng.randi_range(1, 3)
			new_price[currency_name] = amount
	
	return new_price
