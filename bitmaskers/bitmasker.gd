@abstract class_name Bitmasker
extends Node2D


const tilemap_scene: PackedScene = preload("uid://dd4c3njk1hoqb")
const cursor_scene: PackedScene = preload("uid://jqwtriutj0fe")

const CURSOR_SPAWN_DISTANCE: float = 300
const DEAD_ZONE: float = 0.2

const PREVIEW_CELL: Vector2i = Vector2i(1, 0)
const SELECTION_CELL: Vector2i = Vector2i.ZERO


var player: PlayerData
var tilemap_layer: TileMapLayer
## Last frame's trigger value for the select button
var last_trigger_value: float = 0


func _process(_delta: float) -> void:
	var current_trigger: float = Input.get_joy_axis(player.controller_id, JOY_AXIS_TRIGGER_LEFT)

	if last_trigger_value <= DEAD_ZONE and current_trigger > DEAD_ZONE:
		on_select()
	elif last_trigger_value > DEAD_ZONE and current_trigger <= DEAD_ZONE:
		on_unselect()
			
	last_trigger_value = current_trigger
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
			
	if event.is_action_pressed(&"confirm"):
		on_confirm()


## Sets the player for the bitmasker
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
	
	
## Returns a rectangle that should be in view of the camera
## If no constraint is imposed, returns a rectangle of size 0
@abstract func get_camera_rect() -> Rect2

## Returns where the ship should look when selecting
## Often corresponds to the position of the cursor
## If Vector2.INF, the ship continue to look where it would normally
@abstract func get_ship_target_pos() -> Vector2


func global_to_tile(pos: Vector2) -> Vector2i:
	var relative_pos: Vector2 = pos - tilemap_layer.global_position
	return Vector2i(
		floori(relative_pos.x / (tilemap_layer.tile_set.tile_size.x * tilemap_layer.scale.x)),
		floori(relative_pos.y / (tilemap_layer.tile_set.tile_size.y * tilemap_layer.scale.y))
	)
	
	
func tile_to_global(tile_pos: Vector2i) -> Vector2:
	return tile_pos * tilemap_layer.tile_set.tile_size * tilemap_layer.scale.x
	

## Clears the selection
func clear_selection() -> void:
	tilemap_layer.clear()
	selection_complete = true
