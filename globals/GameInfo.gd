extends Node

var max_time: float = 3 * 60 * 1000 #ms
var time_used: float = 0

func _ready() -> void:
	Signals.stat_upgraded.connect(_on_stat_upgraded)

func _on_stat_upgraded(stat: int, amount: float) -> void:
	match stat:
		PlayerInfo.Stat.MAX_TIME:
			max_time += amount
