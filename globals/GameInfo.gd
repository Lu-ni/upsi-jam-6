extends Node

var max_time: float = 3 * 60 * 1000 #ms
var throw_trash_time: int = 1000
var amount_of_trash_collected: int = 0
#var thing_idk

var time_used: float = 0

func _ready() -> void:
	Signals.stat_upgraded.connect(_on_stat_upgraded)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.MAX_TIME:
			max_time += amount
var has_seen_craft_tuto: bool = false
var has_seen_shop_tuto: bool = false
