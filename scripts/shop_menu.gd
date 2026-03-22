extends Node2D

var shop_owner = null
var slot_index: int = 0
var is_craft = false

@onready var item_label = %ItemLabel
@onready var price_label = %PriceLabel
@onready var buy_button = %BuyButton
@onready var currency_icon = %CurrencyIcon
@onready var reroll_price_label = %RerollPriceLabel
@onready var reroll_currency_icon = %RerollCurrencyIcon
@onready var reroll_button = %RerollButton
@onready var bubble = $Bubble

var money_icon_path = "res://assets/sprites/Menu/assets_menu6.png"
var kamas_path = "res://assets/test/kamas.jpg"

func _ready():
	if not buy_button: buy_button = find_child("BuyButton", true, false)

	if currency_icon:
		if ResourceLoader.exists(money_icon_path):
			var tex = load(money_icon_path)
			currency_icon.texture = tex
			if reroll_currency_icon: reroll_currency_icon.texture = tex

	update_display()

	if buy_button: buy_button.pressed.connect(_on_buy_button_pressed)
	if reroll_button: reroll_button.pressed.connect(_on_reroll_button_pressed)

	if bubble:
		bubble.modulate.a = 0.0
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(bubble, "modulate:a", 1.0, 0.25)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shop_buy") or (event is InputEventKey and event.pressed and event.keycode == KEY_X):
		_on_buy_button_pressed()
	elif event.is_action_pressed("shop_reroll") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
		_on_reroll_button_pressed()

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
			if GlobalItemList.items.has(currency):
				new_icon.texture = GlobalItemList.items[currency].texture
			new_icon.show()
			price_container.add_child(new_icon)


	var current_reroll_price = shop_owner.get_current_reroll_price()
	if reroll_price_label:
		reroll_price_label.text = str(current_reroll_price)

	if reroll_currency_icon:
		if "use_precious_for_reroll" in shop_owner and shop_owner.use_precious_for_reroll:
			if ResourceLoader.exists(money_icon_path):
				reroll_currency_icon.texture = load(money_icon_path)
		else:
			if ResourceLoader.exists(kamas_path):
				reroll_currency_icon.texture = load(kamas_path)

	if shop_owner.has_method("can_player_afford_reroll"):
		reroll_button.modulate = Color(1,1,1) if shop_owner.can_player_afford_reroll() else Color(1,1,1)

	buy_button.modulate = Color(1,1,1) if shop_owner.can_player_afford(deal) else Color(1,1,1)

func _on_buy_button_pressed():
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

func _on_reroll_button_pressed():
	if shop_owner == null: return

	if shop_owner.has_method("can_player_afford_reroll") and not shop_owner.can_player_afford_reroll():
		print("Pas assez de ressources pour reroll")
		return

	if shop_owner.has_method("pay_for_reroll"):
		shop_owner.pay_for_reroll()

	var count = shop_owner.get("reroll_count") if "reroll_count" in shop_owner else 0
	var current_price = shop_owner.get_current_reroll_price()

	var new_price = ShopManager.get_next_price(
		ShopManager.current_algo_type,
		current_price,
		count,
		10
	)

	shop_owner.update_reroll_price(new_price)
	if "reroll_count" in shop_owner:
		shop_owner.reroll_count += 1

	shop_owner.reroll_shop()

	print("Reroll used! New price: ", new_price)
	update_display()
