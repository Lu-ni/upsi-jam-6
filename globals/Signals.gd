extends Node

# EXAMPLES
signal pick_up (item: Item)
signal inventory_updated
signal throw (item: Item)
signal times_up
signal gain_score(score: int)

# Upgrade system
signal upgrade_stat(stat: int, rarity: int)
signal stat_upgraded(stat: int, amount: float)
signal trash_added
signal trash_removed

signal MULT_UP
