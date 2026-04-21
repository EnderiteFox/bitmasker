class_name MultiplyModifierComponent
extends RefCounted

static var _multipliers: Dictionary[int, float]


# set a multiplier using it's id and multiplier
func set_multiplier(id: int, multiplier: float) -> void:
	_multipliers[id] = multiplier


# remove markiplier using his id 🥵
func remove_multiplier(id: int) -> void:
	_multipliers.erase(id)


# get the total of all multipliers
func get_multiplier() -> float:
	return _multipliers.values().reduce(
		func(acc: float, val: float) -> float: 
			return acc * val, 1.0
	)
