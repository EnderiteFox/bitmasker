class_name PlayerLoadoutSelector
extends Control


const CURSOR_MOVE_EASING: float = 20
const DEAD_ZONE: float = 0.2
const PLAYER_ROTATION_EASING: float = TAU


var player: PlayerData
var bitmasker_focused: bool = true
var bitmasker_selected: bool = false
var ability_selected: bool = false
var player_texture_target_rotation: float = 0


@onready var player_texture: TextureRect = %PlayerTexture
@onready var bitmasker_selector: InlineSelector = %BitmaskerSelector
@onready var ability_selector: InlineSelector = %AbilitySelector
@onready var cursor: Panel = %Cursor


func _ready() -> void:
	player_texture.pivot_offset_ratio = Vector2(0.5, 0.5)
	player_texture.modulate = player.color
	bitmasker_selector.update_infos()
	ability_selector.update_infos()
	
	bitmasker_selector.custom_minimum_size.x = max(
		bitmasker_selector.custom_minimum_size.x,
		ability_selector.custom_minimum_size.x
	)
	ability_selector.custom_minimum_size.x = max(
		bitmasker_selector.custom_minimum_size.x,
		ability_selector.custom_minimum_size.x
	)


func _process(delta: float) -> void:
	cursor.custom_minimum_size = bitmasker_selector.get_combined_minimum_size()
	
	var cursor_target_position: Vector2
	if bitmasker_focused:
		cursor_target_position = bitmasker_selector.global_position
	else:
		cursor_target_position = ability_selector.global_position
		
	cursor.global_position = lerp(
		cursor.global_position, 
		cursor_target_position, 
		CURSOR_MOVE_EASING * delta
	)
	
	var joystick_direction: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_Y)
	)
	if joystick_direction.length() > DEAD_ZONE:
		player_texture_target_rotation = -joystick_direction.angle_to(Vector2.UP)
		
	player_texture.rotation = lerp_angle(
		player_texture.rotation,
		player_texture_target_rotation,
		PLAYER_ROTATION_EASING * delta
	)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.device != player.controller_id:
		return
	
	
	if event.is_action_pressed(&"controller_down") or event.is_action_pressed(&"controller_up"):
		bitmasker_focused = not bitmasker_focused
		
	if event.is_action_pressed(&"controller_right") and _can_switch_element():
		var selector: InlineSelector = bitmasker_selector if bitmasker_focused else ability_selector
		selector.selected_index += 1
		
	if event.is_action_pressed(&"controller_left") and _can_switch_element():
		var selector: InlineSelector = bitmasker_selector if bitmasker_focused else ability_selector
		selector.selected_index -= 1
		
	if event.is_action_pressed(&"confirm"):
		if bitmasker_focused:
			bitmasker_selected = true
			bitmasker_selector.ability_texture.modulate = player.color
		else:
			ability_selected = true
			ability_selector.ability_texture.modulate = player.color
			
	if event.is_action_pressed(&"cancel"):
		if bitmasker_focused:
			bitmasker_selected = false
			bitmasker_selector.ability_texture.modulate = Color.WHITE
		else:
			ability_selected = false
			ability_selector.ability_texture.modulate = Color.WHITE
	
func init_cursor() -> void:
	cursor.global_position = bitmasker_selector.global_position
	
	
func confirm_loadout() -> void:
	var bitmasker_loadout_item: LoadoutItem = bitmasker_selector.get_selected_element()
	player.bitmasker = bitmasker_loadout_item.item_script.new()
	player.bitmasker.id = bitmasker_loadout_item.id
	var ability_loadout_item: LoadoutItem = ability_selector.get_selected_element()
	player.ability = ability_loadout_item.item_script.new()
	player.ability.id = ability_loadout_item.id
	
	
func _can_switch_element() -> bool:
	return (bitmasker_focused and not bitmasker_selected) or (not bitmasker_focused and not ability_selected)
