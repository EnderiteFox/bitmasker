class_name PlayerData
extends RefCounted


## The controller id of the player
## -1 if the player is using the keyboard
var controller_id: int

## The color of the player, affecting their ship and other cosmetic changes
var color: Color

## The in-game player ship
var ship: PlayerShip

## The bitmasker of the player
var bitmasker: Bitmasker

var ability: Ability


func init_player(p_ship: PlayerShip) -> void:
	self.ship = p_ship
	
	ship.add_child(bitmasker)
	ship.add_child(ability)
	
	ability.player = self
	ship.set_player(self)
	bitmasker.set_player(self)
	
	bitmasker.init_bitmasker()
	ability.init_ability()
