@abstract class_name Ability
extends Node


const AFTER_ABILITY_COOLDOWN: float = 5


var activated: bool = false
var complexity: int = 0


var player: PlayerData
var bitmasker: Bitmasker:
	get():
		return null if player == null else player.bitmasker
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
		
	if event.is_action_pressed(&"ability") and bitmasker != null and bitmasker.selection_complete and not activated:
		activate()
		
		
## Initialized the ability
## Called once the player, ship and bitmasker have been created
func init_ability() -> void:
	pass


## Called when activating the ability
@abstract func activate() -> void


## Disables the ability
func deactivate() -> void:
	activated = false
	bitmasker.clear_selection()
	get_tree().create_timer(AFTER_ABILITY_COOLDOWN).timeout.connect(
		func() -> void:
			bitmasker.can_select = true
	)
