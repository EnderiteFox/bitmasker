class_name PvpGame
extends GameInstance


const maps: Array[PackedScene] = [
	preload("uid://dby6dfhhwlgc"),
	preload("uid://cta62jwvbhmq4"),
	preload("uid://dihl3s10lvbcx"),
	preload("uid://b5bcad6m74hvo")
]


var map: Map


func start_game() -> void:
	var map_scene: PackedScene = maps.pick_random()
	map = map_scene.instantiate()
	self.add_child(map)
	
	for player: PlayerData in Game.players:
		var spawn_point: Vector2 = map.spawn_points.pick_random()
		map.spawn_points.erase(spawn_point)
		
		var player_ship: PlayerShip = ship_scene.instantiate()
		self.add_child(player_ship)
		player_ship.global_position = map.to_global(spawn_point)
		
		player.init_player(player_ship)
		
	game_started.emit()
