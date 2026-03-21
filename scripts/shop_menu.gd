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
	
	# Utilisation de la méthode spécifique pour récupérer l'item du slot visible
	var item = shop_owner.get_item_at_slot(current_index)
	# Si l'index est invalide (au tout début), on ne fait rien
	if item.is_empty(): return

	if item_label: item_label.text = item["name"]
	if desc_label: desc_label.text = item.get("desc", "")
	if price_label: price_label.text = str(item["price"])
	
	if item_icon and item.has("icon"):
		if ResourceLoader.exists(item["icon"]):
			item_icon.texture = load(item["icon"])
	
	var current_reroll_price = shop_owner.get_current_reroll_price()
	if reroll_price_label:
		reroll_price_label.text = str(current_reroll_price)

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
		var item = shop_owner.get_item_at_slot(current_index)
		if item.is_empty(): return
		
		var current_price = item["price"]
		
		# Récupère le nombre d'objets déjà achetés (0 par défaut)
		var count = item.get("count", 0) 
		
		# Calcul du prochain prix avec l'algorithme choisi
		var new_price = ShopManager.get_next_price(
			ShopManager.current_algo_type,
			current_price,
			count,
			1 # Prix de base approximatif
		)
		
		# Mise à jour du prix et du compteur
		shop_owner.update_item_price_at_slot(current_index, new_price)
		item["count"] = count + 1 
		
		print("Buy item: ", item["name"], " (new price: ", new_price, ") [Algo: ", ShopManager.Algo.keys()[ShopManager.current_algo_type], "]")
		
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
