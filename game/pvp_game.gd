class_name PvpGame
extends GameInstance


func start_game() -> void:
	for player: PlayerData in Game.players:
		var player_ship: PlayerShip = ship_scene.instantiate()
		player_ship.set_player(player)
		player.ship = player_ship
		self.add_child(player_ship)
		player_ship.global_position = Vector2.ZERO
