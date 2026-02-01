@abstract class_name Bitmasker
extends Node2D


const tilemap_scene: PackedScene = preload("uid://dd4c3njk1hoqb")
const cursor_scene: PackedScene = preload("uid://jqwtriutj0fe")

## How far the cursor spawns
const CURSOR_SPAWN_DISTANCE: float = 300
const DEAD_ZONE: float = 0.2
## How long before the selection becomes unstable
const SELECTION_STABILITY_DURATION: float = 10
## How long between two tiles disappearing when the selection is unstable
const UNSTABILITY_INTERVAL: float = 0.5

const PREVIEW_CELL: Vector2i = Vector2i(1, 0)
const SELECTION_CELL: Vector2i = Vector2i.ZERO


var player: PlayerData
var ability: Ability
var tilemap_layer: TileMapLayer
## Last frame's trigger value for the select button
var last_trigger_value: float = 0

## How long before the selection becomes unstable
var remaining_stability: float = SELECTION_STABILITY_DURATION

## Which players are in the selected area
var players_in_selection: Array[PlayerData]

## True when the selection has been confirmed
var selection_complete: bool = false
## True if the player is currently able to select
var can_select: bool = true


func _ready() -> void:
	Game.game_instance.game_started.connect(_on_game_started)
	reset_stability()


func _process(delta: float) -> void:
	var current_trigger: float = Input.get_joy_axis(player.controller_id, JOY_AXIS_TRIGGER_LEFT)

	if last_trigger_value <= DEAD_ZONE and current_trigger > DEAD_ZONE:
		on_select()
	elif last_trigger_value > DEAD_ZONE and current_trigger <= DEAD_ZONE:
		on_unselect()
			
	last_trigger_value = current_trigger
	
	if selection_complete and not ability.activated and loses_stability():
		remaining_stability -= delta * get_stability_multiplier()
	
	if remaining_stability <= -UNSTABILITY_INTERVAL:
		remaining_stability = 0
		apply_unstability()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
			
	if event.is_action_pressed(&"confirm"):
		on_confirm()


## Initialized the bitmasker with a player
func set_player(player_data: PlayerData) -> void:
	self.player = player_data
	self.tilemap_layer = tilemap_scene.instantiate()
	self.tilemap_layer.modulate = player_data.color
	player_data.ship.add_child(self)
	player_data.ship.add_sibling(self.tilemap_layer)
	player_data.bitmasker = self
	
	
## Spawn a cursor in front of the player's ship
func spawn_cursor() -> BitmaskCursor:
	var global_spawn_pos: Vector2 = player.ship.global_position + Vector2.RIGHT.rotated(player.ship.global_rotation) * CURSOR_SPAWN_DISTANCE
	var cursor: BitmaskCursor = cursor_scene.instantiate()
	cursor.bitmasker = self
	player.ship.add_sibling(cursor)
	cursor.set_tile_position_instant(global_to_tile(global_spawn_pos - cursor.texture.get_size() * cursor.scale))
	cursor.modulate = player.color
	return cursor
	
	
## Called when pressing the select button
func on_select() -> void:
	pass


## Called when releasing the select button
func on_unselect() -> void:
	pass


## Called when pressing the confirm button
func on_confirm() -> void:
	pass
	
	
## Returns the multiplier for stability
func get_stability_multiplier() -> float:
	return 1.0
	
	
## Returns true if the selection can lose stability
func loses_stability() -> bool:
	return true
	
	
## Returns a rectangle that should be in view of the camera
## If no constraint is imposed, returns a rectangle of size 0
@abstract func get_camera_rect() -> Rect2

## Returns where the ship should look when selecting
## Often corresponds to the position of the cursor
## If Vector2.INF, the ship continue to look where it would normally
@abstract func get_ship_target_pos() -> Vector2


## Turns a global position into tile coordinates
func global_to_tile(pos: Vector2) -> Vector2i:
	var relative_pos: Vector2 = pos - tilemap_layer.global_position
	return Vector2i(
		floori(relative_pos.x / (tilemap_layer.tile_set.tile_size.x * tilemap_layer.scale.x)),
		floori(relative_pos.y / (tilemap_layer.tile_set.tile_size.y * tilemap_layer.scale.y))
	)
	
	
## Turns tile coordinates into a global position
func tile_to_global(tile_pos: Vector2i) -> Vector2:
	return tile_pos * tilemap_layer.tile_set.tile_size * tilemap_layer.scale.x
	
	
## Resets the stability timer
func reset_stability() -> void:
	remaining_stability = SELECTION_STABILITY_DURATION - UNSTABILITY_INTERVAL
	
	
## Removes a random tile from the selection
func apply_unstability() -> void:
	var cells: Array[Vector2i] = tilemap_layer.get_used_cells_by_id(1, SELECTION_CELL)
	
	if cells.is_empty():
		clear_selection()
		reset_stability()
		can_select = true
		return

	var removed_cell: Vector2i = cells.pick_random()
	tilemap_layer.set_cell(removed_cell)
	
	
## Confirms the validation, setting the cooldown before selecting again
func confirm_validation() -> void:
	selection_complete = true
	reset_stability()
	can_select = false
	

## Clears the selection
func clear_selection() -> void:
	tilemap_layer.clear()
	selection_complete = false
	
	
func can_start_select() -> bool:
	return can_select and not ability.activated
	
	
## Called when the game starts
func _on_game_started() -> void:
	for player_data: PlayerData in Game.players:
		player_data.ship.entered_selection.connect(_on_player_enters_selection.bind(player_data))
		player_data.ship.exited_selection.connect(_on_player_exits_selection.bind(player_data))
		
		
func _on_player_enters_selection(selection: TileMapLayer, player_data: PlayerData) -> void:
	if selection != tilemap_layer or players_in_selection.has(player_data):
		return
	
	players_in_selection.append(player_data)
	
	
func _on_player_exits_selection(selection: TileMapLayer, player_data: PlayerData) -> void:
	if selection != tilemap_layer:
		return
		
	players_in_selection.erase(player_data)
