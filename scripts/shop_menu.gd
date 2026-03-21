extends Node2D

var shop_owner = null
var current_index = 1
var money_icon_path = "res://assets/test/Diamante.png"

@onready var item_label = %ItemLabel
@onready var price_label = %PriceLabel
@onready var desc_label = %DescLabel
@onready var left_button = %LeftButton
@onready var right_button = %RightButton
@onready var buy_button = %BuyButton
@onready var item_icon = %ItemIcon
@onready var currency_icon = %CurrencyIcon
@onready var reroll_price_label = %RerollPriceLabel
@onready var reroll_currency_icon = %RerollCurrencyIcon
@onready var reroll_button = %RerollButton

func _ready():
	if not left_button: left_button = find_child("LeftButton", true, false)
	if not right_button: right_button = find_child("RightButton", true, false)
	if not buy_button: buy_button = find_child("BuyButton", true, false)

	if currency_icon:
		if ResourceLoader.exists(money_icon_path):
			var tex = load(money_icon_path)
			currency_icon.texture = tex
			if reroll_currency_icon: reroll_currency_icon.texture = tex

	update_display()

	if left_button: left_button.pressed.connect(_on_left_button_pressed)
	if right_button: right_button.pressed.connect(_on_right_button_pressed)
	if buy_button: buy_button.pressed.connect(_on_buy_button_pressed)
	if reroll_button: reroll_button.pressed.connect(_on_reroll_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shop_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_LEFT):
		_on_left_button_pressed()
	elif event.is_action_pressed("shop_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_RIGHT):
		_on_right_button_pressed()
	elif event.is_action_pressed("shop_buy") or (event is InputEventKey and event.pressed and event.keycode == KEY_X) or (event is InputEventKey and event.pressed and event.keycode == KEY_DOWN):
		_on_buy_button_pressed()
	elif event.is_action_pressed("shop_reroll") or(event is InputEventKey and event.pressed and event.keycode == KEY_R) or (event is InputEventKey and event.pressed and event.keycode == KEY_UP):
		_on_reroll_button_pressed()

func update_display():
	if shop_owner == null: return
	
	# Utilisation de la méthode spécifique pour récupérer le Deal du slot visible
	var deal: Deal = shop_owner.get_item_at_slot(current_index)
	if deal == null: return

	if item_label: item_label.text = deal.item_name
	if desc_label: desc_label.text = deal.desc
	
	# Gestion dynamique des icônes et prix multiples
	if price_label and currency_icon:
		var price_container = price_label.get_parent()
		# Nettoyer les anciens enfants générés (sauf les deux originaux qu'on va utiliser comme template)
		for child in price_container.get_children():
			if child != price_label and child != currency_icon:
				child.queue_free()
		
		# On cache les originaux s'il n'y a pas de prix, mais on s'en sert de modèle
		price_label.hide()
		currency_icon.hide()
		
		# Affichage des prix sous forme de multiples Labels/Icons
		for currency in deal.current_price.keys():
			var price_val = deal.current_price[currency]
			
			var new_lbl = price_label.duplicate()
			new_lbl.text = str(price_val)
			new_lbl.show()
			price_container.add_child(new_lbl)
			
			var new_icon = currency_icon.duplicate()
			if GlobalItemList.items.has(currency):
				new_icon.texture = GlobalItemList.items[currency].texture
			new_icon.show()
			price_container.add_child(new_icon)
	
	if item_icon and deal.texture_path != "":
		if ResourceLoader.exists(deal.texture_path):
			item_icon.texture = load(deal.texture_path)
	
	var current_reroll_price = shop_owner.get_current_reroll_price()
	if reroll_price_label:
		reroll_price_label.text = str(current_reroll_price)

	# Vérification des fonds pour le bouton d'achat
	if shop_owner.can_player_afford(deal):
		buy_button.modulate = Color(1, 1, 1) # Normal
	else:
		buy_button.modulate = Color(1, 0, 0) # Rouge si pas assez d'argent

func _on_left_button_pressed():
	if shop_owner:
		current_index = (current_index - 1 + shop_owner.SHOP_SLOTS_COUNT) % shop_owner.SHOP_SLOTS_COUNT
		update_display()

func _on_right_button_pressed():
	if shop_owner:
		current_index = (current_index + 1) % shop_owner.SHOP_SLOTS_COUNT
		update_display()

func _on_buy_button_pressed():
	if shop_owner:
		var deal: Deal = shop_owner.get_item_at_slot(current_index)
		if deal == null: return
		
		# Vérifie si on peut payer
		if not shop_owner.can_player_afford(deal):
			print("Pas assez de ressources pour acheter ", deal.item_name)
			return
			
		# Paye l'item
		shop_owner.pay_for_deal(deal)
		
		# Applique la récompense
		shop_owner.grant_reward(deal.reward_id)
		
		var current_price = deal.current_price
		var count = deal.count 
		
		# Calcul du prochain prix avec l'algorithme choisi pour chaque devise
		var new_price_dict = ShopManager.get_next_price_dict(
			ShopManager.current_algo_type,
			current_price,
			count,
			deal.base_price
		)

		# Mise à jour du prix et du compteur
		shop_owner.update_item_price_at_slot(current_index, new_price_dict)
		deal.count = count + 1 
		
		print("Buy deal: ", deal.item_name, " (new price dict: ", new_price_dict, ") [Algo: ", ShopManager.Algo.keys()[ShopManager.current_algo_type], "]")
		
		# Remplacement de l'item acheté par un nouveau aléatoire
		shop_owner.replace_item_at_slot(current_index)

		update_display()

func _on_reroll_button_pressed():
	if shop_owner:
		var current_price = shop_owner.get_current_reroll_price()

		# On suppose que le shop owner gère son compteur de reroll
		var count = shop_owner.get("reroll_count") if "reroll_count" in shop_owner else 0

		var new_price = ShopManager.get_next_price(
			ShopManager.current_algo_type,
			current_price,
			count,
			10 # Prix de base pour le reroll
		)

		shop_owner.update_reroll_price(new_price)
		if "reroll_count" in shop_owner:
			shop_owner.reroll_count += 1

		# Reroll complet du shop !
		shop_owner.reroll_shop()

		print("Reroll used! New price: ", new_price)
		update_display()
