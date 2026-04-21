class_name PvpGame
extends GameInstance


const maps: Array[PackedScene] = [
	preload("uid://dby6dfhhwlgc"),
	preload("uid://cta62jwvbhmq4"),
	preload("uid://dihl3s10lvbcx"),
	preload("uid://b5bcad6m74hvo")
]
const END_ANIMATION_TIME: float = 5


## Used in the end animation to prevent starting it multiple times
var end_animation_started: bool = false


func start_game() -> void:
	var map_scene: PackedScene = maps.pick_random()
	Game.map = map_scene.instantiate()
	self.add_child(Game.map)
	
	for player: PlayerData in Game.players:
		var spawn_point: Vector2 = Game.map.spawn_points.pick_random()
		Game.map.spawn_points.erase(spawn_point)
		
		var player_ship: PlayerShip = ship_scene.instantiate()
		self.add_child(player_ship)
		player_ship.global_position = Game.map.to_global(spawn_point)
		player_ship.destroyed.connect(_on_player_death.bind(player))
		
		player.init_player(player_ship)
		
	game_started.emit()
	
	
func _on_player_death(player: PlayerData) -> void:
	player.ship.queue_free()
	player.bitmasker.queue_free()
	player.ability.queue_free()
	_remove_player.call_deferred(player)
		
		
func _remove_player(player: PlayerData) -> void:
	player.ship = null
	player.ability = null
	player.bitmasker = null
	
	var alive_players: Array[PlayerData] = Game.players.filter(
		func(other_player: PlayerData) -> bool:
			return other_player.ship != null
	)
	if alive_players.size() <= 1:
		_on_game_end()
	
	
func _on_game_end() -> void:
	if end_animation_started:
		return
		
	end_animation_started = true
		
	get_tree().create_timer(END_ANIMATION_TIME).timeout.connect(
		func() -> void:
			get_tree().change_scene_to_file("uid://ddtgh0dts4fgf")
	)
	

func _get_validation_conditions() -> Array[ValidationCondition]:
	var conditions: Array[ValidationCondition] = []
	
	for map_scene: PackedScene in maps:
		conditions.append(ValidationCondition.is_scene_of_type(map_scene, Map))
	
	return conditions
