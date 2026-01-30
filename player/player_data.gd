class_name PlayerData
extends RefCounted


## The controller id of the player
## -1 if the player is using the keyboard
var controller_id: int

## The color of the player, affecting their ship and other cosmetic changes
var color: Color

## The in-game player ship
var ship: PlayerShip
