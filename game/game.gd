class_name Game
extends RefCounted


const MAX_PLAYERS: int = 8

static var players: Array[PlayerData]

## The game instance for the current game mode
static var game_instance: GameInstance

static var map: Map


## Starts the game with the current game mode
static func start_game() -> void:
	if not game_instance:
		push_error("Can't start game with no game instance")
		return
		
	game_instance.start_game()
	
	
## Registers a body as entering a selection
static func process_selection_entered(body: Node2D, tilemap: TileMapLayer) -> void:
	for player: PlayerData in players:
		if player.bitmasker != null and player.bitmasker.tilemap_layer == tilemap:
			player.bitmasker.body_entered_selection.emit(body)
			
			
## Registers a body as exiting a selection
static func process_selection_exited(body: Node2D, tilemap: TileMapLayer) -> void:
	for player: PlayerData in players:
		if player.bitmasker != null and player.bitmasker.tilemap_layer == tilemap:
			player.bitmasker.body_exited_selection.emit(body)
