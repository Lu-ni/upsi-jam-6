extends Node
enum Algo {
	FIBO,
	LINEAR,
	EXPONENTIAL,
	GEOMETRIC
}
@export var DEBUG = false

# Variable pour switcher l'algo depuis n'importe où
var current_algo_type: Algo = Algo.EXPONENTIAL

# Variable globale pour le prix du reroll (si activé)
var global_reroll_price: int = 10

const MAX_PRICE = 75025


func _input(event: InputEvent) -> void:
	if (DEBUG == true):
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
			current_algo_type = ((current_algo_type + 1) % Algo.size()) as Algo
			#print("Algo changé pour : ", Algo.keys()[current_algo_type])

func get_next_price(algo_type: Algo, current_price: int, count: int, base_price: int = 10) -> int:
	var new_price = current_price
	
	match algo_type:
		Algo.FIBO:
			new_price = get_next_fibonacci(current_price)
			
		Algo.LINEAR:
			# Prix = Base + (NombreAchetés * AugmentationFixe)
			new_price = base_price + ((count + 1) * 15) 
			
		Algo.EXPONENTIAL:
			# Prix = Base * (Multiplicateur ^ NombreAchetés)
			new_price = int(base_price * pow(1.15, count + 1))
			
		Algo.GEOMETRIC:
			# Progressif : on ajoute un peu plus à chaque fois (Accumulation)
			new_price = current_price + ((count + 1) * 10)

	if new_price > MAX_PRICE:
		return MAX_PRICE
		
	return new_price 
	
# Applique la formule d'inflation sur toutes les devises exigées
func get_next_price_dict(algo_type: Algo, current_price: Dictionary, count: int, base_price: Dictionary) -> Dictionary:
	var new_prices = {}
	for currency in current_price.keys():
		var c_val = current_price[currency]
		var b_val = base_price.get(currency, 1)
		new_prices[currency] = get_next_price(algo_type, c_val, count, b_val)
	return new_prices

func check_max_price(current_price: int) -> bool:
	return current_price < MAX_PRICE

func get_next_fibonacci(current_val: int) -> int:
	if not check_max_price(current_val):
		return MAX_PRICE

	var a = 1
	var b = 2
	
	if current_val < 2:
		return 2

	while b <= current_val:
		var temp = a + b
		a = b
		b = temp
	
	return b
