class_name MultiplyModifierComponent
extends RefCounted

static var _multipliers: Dictionary[int, float]


func set_multiplier(id: int, multiplier: float) -> void:
	_multipliers[id] = multiplier


func get_multiplier() -> float:
	return _multipliers.values().reduce(
		func(acc: float, val: float) -> float: 
			return acc * val, 1.0
	)
