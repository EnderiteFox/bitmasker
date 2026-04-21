@abstract class_name Bitmasker
extends Node2D


signal body_entered_selection(body: Node2D)
signal body_exited_selection(body: Node2D)


const tilemap_scene: PackedScene = preload("uid://dd4c3njk1hoqb")
const cursor_scene: PackedScene = preload("uid://jqwtriutj0fe")
const ability_particle_scene: PackedScene = preload("uid://bwmu0wamsapy0")
const abilities: LoadoutItemDatabase = preload("uid://bjduj8i1oeri6")

## How far the cursor spawns
const CURSOR_SPAWN_DISTANCE: float = 300
const DEAD_ZONE: float = 0.2
## How long before the selection becomes unstable
const SELECTION_STABILITY_DURATION: float = 4
## How long between two tiles disappearing when the selection is unstable
const UNSTABILITY_INTERVAL: float = 0.25

## The delay between two particles
const PARTICLE_INTERVAL: float = 0.1
const INACTIVE_PARTICLE_OPACITY: float = 0.35
const ACTIVE_PARTICLE_OPACITY: float = 0.8
const PARTICLE_MOVE_SPEED: float = 0.25
const PARTICLE_SCALE: float = 2.5

## Tilemap Atlas coordinates of the preview cell
const PREVIEW_CELL: Vector2i = Vector2i(1, 0)
## Tilemap Atlas coordinates of the selection cell
const SELECTION_CELL: Vector2i = Vector2i.ZERO


var player: PlayerData
var ability: Ability:
	get:
		return player.ability
var tilemap_layer: TileMapLayer
## Last frame's trigger value for the select button
var last_trigger_value: float = 0

## How long before the selection becomes unstable
var remaining_stability: float = SELECTION_STABILITY_DURATION

## Which bodies are in the selected area
var bodies_in_selection: Array[Node2D]

## True when the selection has been confirmed
var selection_complete: bool = false
## True if the player is currently able to select
var can_select: bool = true

var complexity: int = 0

var id: StringName

var emitter: GPUParticles2D

func _ready() -> void:
	Game.game_instance.game_started.connect(_on_game_started)
	reset_stability()
	
	body_entered_selection.connect(_on_body_entered_selection)
	body_exited_selection.connect(_on_body_exited_selection)
	
	self.tree_exiting.connect(_on_exiting_tree)


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
		
		
func _get_validation_conditions() -> Array[ValidationCondition]:
	return [
		ValidationCondition.is_scene_of_type(tilemap_scene, CanvasGroup),
		ValidationCondition.is_scene_of_type(cursor_scene, BitmaskCursor),
		ValidationCondition.is_scene_of_type(ability_particle_scene, AbilityParticle)
	]
	
	
## Initializes the bitmasker	
func init_bitmasker() -> void:
	emit_particle()
	
	
func emit_particle() -> void:
	var tilemap_rect: Rect2i = tilemap_layer.get_used_rect()
	if tilemap_rect.size != Vector2i.ZERO:
		var selected_tile: Vector2i = tilemap_layer.get_used_cells().pick_random()
		var pos_in_tile: Vector2 = Vector2(randf(), randf())
		var particle_pos: Vector2 = tile_to_global(selected_tile) + tile_to_global(pos_in_tile)
		
		var ability_particle: AbilityParticle = ability_particle_scene.instantiate()
		Game.map.add_child(ability_particle)
		ability_particle.global_position = particle_pos
		
		var ability_activation: AbilityParticle.ActivationType
		if ability.activated:
			ability_activation = AbilityParticle.ActivationType.ACTIVE
		elif selection_complete:
			ability_activation = AbilityParticle.ActivationType.SELECTED
		else:
			ability_activation = AbilityParticle.ActivationType.PRESELECTION
		
		ability_particle.init(
			abilities.get_from_id(ability.id).texture,
			player.color,
			ability_activation
		)
		
	get_tree().create_timer(PARTICLE_INTERVAL).timeout.connect(emit_particle)


## Initializes the bitmasker with a player
func set_player(player_data: PlayerData) -> void:
	self.player = player_data
	var tilemap_layer_root: Node2D = tilemap_scene.instantiate()
	self.tilemap_layer = tilemap_layer_root.get_child(0)
	self.tilemap_layer.modulate = player_data.color
	player_data.ship.add_child(tilemap_layer_root)
	tilemap_layer_root.top_level = true
	
	
## Spawn a cursor in front of the player's ship
func spawn_cursor() -> BitmaskCursor:
	var global_spawn_pos: Vector2 = player.ship.global_position + Vector2.RIGHT.rotated(player.ship.global_rotation) * CURSOR_SPAWN_DISTANCE
	var cursor: BitmaskCursor = cursor_scene.instantiate()
	cursor.bitmasker = self
	player.ship.add_child(cursor)
	cursor.top_level = true
	
	var tile_pos: Vector2i = global_to_tile(global_spawn_pos - cursor.texture.get_size() * cursor.scale)
	var map_size: Rect2i = Game.map.get_used_rect()
	
	tile_pos.x = clamp(tile_pos.x, map_size.position.x, map_size.position.x + map_size.size.x - 1)
	tile_pos.y = clamp(tile_pos.y, map_size.position.y, map_size.position.y + map_size.size.y - 1)
	
	cursor.set_tile_position_instant(tile_pos)
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
func tile_to_global(tile_pos: Vector2) -> Vector2:
	return tile_pos * (tilemap_layer.tile_set.tile_size * tilemap_layer.scale.x)
	
	
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
	pass
	
	
## Called when an entity enters the selection
func _on_body_entered_selection(body: Node2D) -> void:
	if not bodies_in_selection.has(body):
		bodies_in_selection.append(body)
		body.tree_exiting.connect(_on_body_exiting_tree)
		
		
func _on_body_exited_selection(body: Node2D) -> void:
	bodies_in_selection.erase(body)
	if body.tree_exiting.is_connected(_on_body_exiting_tree):
		body.tree_exiting.disconnect(_on_body_exiting_tree)
	
	
func _on_body_exiting_tree(body: Node2D) -> void:
	body_exited_selection.emit(body)
	
	
func _on_exiting_tree() -> void:
	for body: Node2D in bodies_in_selection:
		body_exited_selection.emit(body)
