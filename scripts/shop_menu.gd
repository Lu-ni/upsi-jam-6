extends Node2D

var shop_owner = null
var slot_index: int = 0
var is_craft = false

@export var window_color: Color = Color("ffffff")

@onready var item_label = %ItemLabel
@onready var price_label = %PriceLabel
@onready var currency_icon = %CurrencyIcon
@onready var item_icon = get_node_or_null("%ItemIcon") # On remet l'icône de l'objet
@onready var bubble = $Bubble

var money_icon_path = "res://assets/sprites/items-and-more/Diamand_money.svg"
var kamas_path = "res://assets/test/kamas.jpg"

func _ready():
	# Si item_icon n'a pas été trouvé avec get_node_or_null, on tente une deuxième fois
	if not item_icon: item_icon = find_child("ItemIcon", true, false)

	if currency_icon:
		if ResourceLoader.exists(money_icon_path):
			var tex = load(money_icon_path)
			currency_icon.texture = tex

	update_display()

	if bubble:
		# Créer un bouton invisible dynamique par-dessus la bulle
		var invisible_btn = Button.new()
		invisible_btn.flat = true 
		invisible_btn.focus_mode = Control.FOCUS_NONE 
		
		# On place ce bouton à la racine et en premier plan pour qu'AUCUN
		# autre élément (comme le texte ou l'icône) ne bloque la souris
		add_child(invisible_btn)
		
		if bubble is Control:
			invisible_btn.position = bubble.position
			invisible_btn.size = bubble.size
		elif bubble.has_method("get_rect"): 
			var rect = bubble.get_rect()
			invisible_btn.position = bubble.position + rect.position
			invisible_btn.size = rect.size
			
		invisible_btn.move_to_front()
		
		# On ne connecte plus les événements sur tout le fond
		# invisible_btn.pressed.connect(_on_bubble_clicked)
		# invisible_btn.mouse_entered.connect(_on_mouse_entered)
		# invisible_btn.mouse_exited.connect(_on_mouse_exited)
		invisible_btn.hide() # On le cache/désactive pour laisser les clics passer au bouton
		
		# Connexion du bouton Acheter
		var buy_button = get_node_or_null("%BuyButton")
		if buy_button:
			if not buy_button.pressed.is_connected(_on_bubble_clicked):
				buy_button.pressed.connect(_on_bubble_clicked)
		
		bubble.modulate = window_color
		bubble.modulate.a = 0.0
		var fade_tween = create_tween()
		fade_tween.set_ease(Tween.EASE_OUT)
		fade_tween.set_trans(Tween.TRANS_SINE)
		fade_tween.tween_property(bubble, "modulate:a", window_color.a, 0.25)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shop_buy") or (event is InputEventKey and event.pressed and event.keycode == KEY_X):
		_on_bubble_clicked()

func update_display():
	if shop_owner == null: return

	var deal: Deal = shop_owner.get_item_at_slot(slot_index)
	if deal == null: return

	if item_label: item_label.text = deal.item_name

	if price_label and currency_icon:
		var price_container = price_label.get_parent()
		for child in price_container.get_children():
			if child != price_label and child != currency_icon:
				child.queue_free()

		price_label.hide()
		currency_icon.hide()

		for currency in deal.current_price.keys():
			var price_val = deal.current_price[currency]

			var new_lbl = price_label.duplicate()
			new_lbl.text = str(price_val)
			new_lbl.show()
			price_container.add_child(new_lbl)

			var new_icon = currency_icon.duplicate()
			
			if is_craft and GlobalItemList.items.has(currency):
				# Si c'est du craft, on met en priorité l'icône de l'item demandé comme monnaie !
				new_icon.texture = GlobalItemList.items[currency].texture
			elif not is_craft and GlobalItemList.items.has(currency):
				# Si ce n'est pas du craft, s'il y a une icône spéciale on peut la prendre
				new_icon.texture = GlobalItemList.items[currency].texture
			else:
				# Sinon ça reste l'icône de l'argent par défaut (money_icon_path) que le currency_icon possède déjà
				pass
				
			print("Currency: ", currency, " has item in GlobalItemList: ", GlobalItemList.items.has(currency))
			new_icon.show()
			price_container.add_child(new_icon)


	# On restaure la logique de l'image de l'ITEM VENDU !
	if item_icon and deal.texture_path != "":
		if ResourceLoader.exists(deal.texture_path):
			item_icon.texture = load(deal.texture_path)

	if bubble: 
		_update_bubble_visuals(deal)

func _update_bubble_visuals(deal: Deal = null):
	if shop_owner == null or not bubble: return
	if deal == null:
		deal = shop_owner.get_item_at_slot(slot_index)
	
	var can_buy = deal != null and shop_owner.can_player_afford(deal)
	
	# Gestion du bouton "Acheter"
	var buy_button = get_node_or_null("%BuyButton")
	if buy_button:
		buy_button.disabled = false
		
		# On peut indiquer visuellement si c'est achetable ou non
		if not can_buy:
			buy_button.modulate = Color(0.8, 0.4, 0.4, 1.0) # Rouge pas trop flashy
		else:
			buy_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_bubble_clicked():
	if shop_owner == null: return

	var deal: Deal = shop_owner.get_item_at_slot(slot_index)
	if deal == null: return

	if not shop_owner.can_player_afford(deal):
		print("Pas assez de ressources pour acheter ", deal.item_name)
		return

	shop_owner.pay_for_deal(deal)
	shop_owner.grant_reward(deal.reward_id)

	var new_price_dict = ShopManager.get_next_price_dict(
		ShopManager.current_algo_type,
		deal.current_price,
		deal.count,
		deal.base_price
	)

	shop_owner.update_item_price_at_slot(slot_index, new_price_dict)
	deal.count += 1

	print("Buy deal: ", deal.item_name, " (new price dict: ", new_price_dict, ") [Algo: ", ShopManager.Algo.keys()[ShopManager.current_algo_type], "]")

	shop_owner.replace_item_at_slot(slot_index)
	update_display()
