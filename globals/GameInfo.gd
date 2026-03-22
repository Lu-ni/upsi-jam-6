extends Node

var max_time: float
var throw_trash_time: int
var amount_of_trash_collected: int
var HOWMUCHTRASHFORMULTUP: int
var score: int
var multiplier: int = 1

var time_left: float
var total_time: float

func _ready() -> void:
	Signals.stat_upgraded.connect(_on_stat_upgraded)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.MAX_TIME:
			time_left += amount
			#print("New time left: ", time_left, "(+", amount,  ")")
var has_seen_craft_tuto: bool = false
var has_seen_shop_tuto: bool = false
