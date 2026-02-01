class_name ColorSelectButton
extends Button
## A button for color selection in player displays


const TAKEN_DARKER_AMOUNT: float = 0.6


@export var color: Color


func _ready() -> void:
	set_free()
	
	
func set_taken() -> void:
	self.modulate = color * TAKEN_DARKER_AMOUNT
	

func set_free() -> void:
	self.modulate = color
