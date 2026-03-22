extends Node

# ── Enums ──
enum Stat { SPEED, PICKUP_RANGE, DROP_SPEED, MAX_INVENTORY, DUMP_RANGE, DUMP_COOLDOWN, MAX_TIME, DROP_VALUE }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC }

# ── Upgrade Config ──
const GLOBAL_MAX_UPGRADES: int = 50
const MAX_UPGRADES: Dictionary = {
	Stat.SPEED: 5, Stat.PICKUP_RANGE: 10, Stat.DROP_SPEED: 8,
	Stat.MAX_INVENTORY: 5, Stat.DUMP_RANGE: 6, Stat.DUMP_COOLDOWN: 8,
	Stat.MAX_TIME: 5, Stat.DROP_VALUE: 5,
}
const UPGRADE_VALUES: Dictionary = {
	Stat.SPEED:         { Rarity.COMMON: 10.0, Rarity.UNCOMMON: 20.0, Rarity.RARE: 35.0, Rarity.EPIC: 50.0 },
	Stat.PICKUP_RANGE:  { Rarity.COMMON: 5.0,  Rarity.UNCOMMON: 12.0, Rarity.RARE: 20.0, Rarity.EPIC: 35.0 },
	Stat.DROP_SPEED:    { Rarity.COMMON: 5.0,  Rarity.UNCOMMON: 10.0, Rarity.RARE: 18.0, Rarity.EPIC: 30.0 },
	Stat.MAX_INVENTORY: { Rarity.COMMON: 3.0,  Rarity.UNCOMMON: 4.0,  Rarity.RARE: 6.0,  Rarity.EPIC: 10.0 },
	Stat.DUMP_RANGE:    { Rarity.COMMON: 5.0,   Rarity.UNCOMMON: 12.0,   Rarity.RARE: 18.0,    Rarity.EPIC: 25.0 },
	Stat.DUMP_COOLDOWN: { Rarity.COMMON: 100.0, Rarity.UNCOMMON: 200.0,  Rarity.RARE: 300.0,   Rarity.EPIC: 500.0 },
	Stat.MAX_TIME:      { Rarity.COMMON: 15000.0, Rarity.UNCOMMON: 30000.0, Rarity.RARE: 50000.0, Rarity.EPIC: 90000.0 },
	Stat.DROP_VALUE:    { Rarity.COMMON: 0.25,   Rarity.UNCOMMON: 0.5,    Rarity.RARE: 1.0,      Rarity.EPIC: 2.0 },
}

# ── Player Data ──
var inventory: Array[Item] = []
var kamas: int
var max_inventory: float = 3

# ── Upgrade Tracking ──
var upgrade_counts: Dictionary = {}
var total_upgrades: int = 0
@export var field_of_view : int = 12 # should not be biger than 20
#var ta_race_jsp

func _ready() -> void:
	for stat in MAX_UPGRADES.keys():
		upgrade_counts[stat] = 0
	Signals.upgrade_stat.connect(_on_upgrade_stat)
	Signals.pick_up.connect(add_item_to_inventory)
	Signals.throw.connect(remove_item_from_inventory)

func can_upgrade(stat: int) -> bool:
	if total_upgrades >= GLOBAL_MAX_UPGRADES:
		return false
	if not MAX_UPGRADES.has(stat):
		return false
	return upgrade_counts.get(stat, 0) < MAX_UPGRADES[stat]

func _on_upgrade_stat(stat: int, rarity: int) -> void:
	if not can_upgrade(stat):
		return
	var amount: float = UPGRADE_VALUES[stat][rarity]
	upgrade_counts[stat] += 1
	total_upgrades += 1
	# Apply stats that live in PlayerInfo directly
	match stat:
		Stat.MAX_INVENTORY:
			max_inventory += amount
		Stat.DROP_VALUE:
			GameInfo.multiplier += amount
	# Broadcast for stats that live on other nodes
	Signals.stat_upgraded.emit(stat, amount)

func _process(wd: float) -> void:
	pass

func add_item_to_inventory(item: Item):
	inventory.append(item)

	Signals.inventory_updated.emit()
func remove_item_from_inventory(item: Item):
	for i in inventory:
		if i == item:
			inventory.erase(i)
			return
