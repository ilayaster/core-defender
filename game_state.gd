extends Node

enum CoreType { SLOW, PLOSIVE }

var selected_core: CoreType = CoreType.SLOW
var game_active: bool = false
var round_time_total: float = 600.0 # 10 минут в секундах
