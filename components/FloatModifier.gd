class_name FloatModifier
extends RefCounted

var _modifiers: Dictionary[int, float]


func set_modifier_for_id(id: int, value: float) -> void:
	_modifiers[id] = value
	
	
func set_modifier(object: Object, value: float) -> void:
	set_modifier_for_id(object.get_instance_id(), value)
	

func remove_modifier_for_id(id: int) -> void:
	_modifiers.erase(id)
	

func remove_modifier(object: Object) -> void:
	remove_modifier_for_id(object.get_instance_id())
	
	
func get_modifier() -> float:
	return _modifiers.values().reduce(
		func(a: float, b: float) -> float:
			return a * b, 1.0
	)
