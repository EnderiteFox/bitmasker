@abstract class_name Ability
extends Node


const AFTER_ABILITY_COOLDOWN: float = 5


var activated: bool = false


var player: PlayerData
var bitmasker: Bitmasker:
	get:
		return player.bitmasker
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
		
	if event.is_action_pressed(&"ability") and bitmasker.selection_complete and not activated:
		activate()


## Called when activating the ability
@abstract func activate() -> void
