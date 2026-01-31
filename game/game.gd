class_name Game
extends RefCounted

const MAX_PLAYERS: int = 8

static var players: Array[PlayerData]

## The game instance for the current game mode
static var game_instance: GameInstance


## Starts the game with the current game mode
static func start_game() -> void:
	if not game_instance:
		push_error("Can't start game with no game instance")
		return
		
	game_instance.start_game()
