@abstract class_name GameInstance
extends Node
## A class with everything that different game modes have in common


@warning_ignore("unused_signal")
signal game_started


const ship_scene: PackedScene = preload("uid://3er7segq5hwn")


@abstract func start_game() -> void

func _get_validation_conditions() -> Array[ValidationCondition]:
	return [
		ValidationCondition.is_scene_of_type(ship_scene, PlayerShip)
	]
