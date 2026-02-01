@abstract class_name Ability
extends Node


var activated: bool = false


var bitmasker: Bitmasker
		
var player: PlayerData:
	get():
		return bitmasker.player
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
		
	if event.is_action_pressed(&"ability") and bitmasker.selection_complete and not activated:
		activate()


## Called when activating the ability
@abstract func activate() -> void
