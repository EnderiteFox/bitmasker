class_name PlayerDisplay
extends Control


signal color_selected(color: Color)
signal color_unselected(color: Color)
## Emitted when a player chooses to disconnect by pressing cancel without a selected color
signal disconnected

const COLOR_BUTTONS_PER_LINE: int = 4
const DEAD_ZONE: float = 0.4
const PLAYER_ROTATION_EASING: float = TAU
const CURSOR_MOVE_RATIO: float = 20

@export var color_select_buttons: Array[ColorSelectButton]

var controller_id: int = -1
var player_texture_target_rotation: float = 0
var taken_colors: Array[Color]
var selected_color: Color = Color.BLACK
var cursor_index: int = 0

@onready var player_texture: TextureRect = %PlayerTexture
@onready var cursor: Control = %Cursor


func _ready() -> void:
	player_texture.pivot_offset_ratio = Vector2(0.5, 0.5)
	cursor.global_position = color_select_buttons[0].global_position
	
	
func _process(delta: float) -> void:
	var joystick_direction: Vector2 = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
	)
	if joystick_direction.length() > DEAD_ZONE:
		player_texture_target_rotation = -joystick_direction.angle_to(Vector2.UP)
		
	player_texture.rotation = lerp_angle(
		player_texture.rotation,
		player_texture_target_rotation,
		PLAYER_ROTATION_EASING * delta
	)
	
	_cursor_process(delta)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton:
		return
		
	if controller_id == -1 or event.device != controller_id:
		return
		
	if event.is_action_pressed(&"controller_down") or event.is_action_pressed(&"controller_up"):
		cursor_index = (cursor_index + 4) % 8
		
	if event.is_action_pressed(&"controller_right"):
		cursor_index = int(cursor_index / 4.0) * 4 + (cursor_index + 1) % 4
		
	if event.is_action_pressed(&"controller_left"):
		cursor_index = int(cursor_index / 4.0) * 4 + (cursor_index - 1) % 4
		
	if event.is_action_pressed(&"select_color"):
		select_color(color_select_buttons[cursor_index].color)
		
	if event.is_action_pressed(&"cancel"):
		if selected_color == Color.BLACK:
			disconnected.emit.call_deferred()
		else:
			unselect_color()
	
	
func select_color(color: Color) -> void:
	if taken_colors.has(color):
		return

	if selected_color != Color.BLACK:
		unselect_color()
		
	selected_color = color
	player_texture.modulate = color
	color_selected.emit(color)
	
	if Input.has_joy_light(controller_id):
		Input.set_joy_light(controller_id, color)
	
	
func unselect_color() -> void:
	if selected_color == Color.BLACK:
		return
		
	var old_color: Color = selected_color
	selected_color = Color.BLACK
	player_texture.modulate = Color.WHITE
	color_unselected.emit(old_color)
	
	
func update_colors() -> void:
	for color_button: ColorSelectButton in color_select_buttons:
		if taken_colors.has(color_button.color):
			color_button.set_taken()
		else:
			color_button.set_free()
			
			
func has_selected_color() -> bool:
	return selected_color != Color.BLACK
	
	
func _cursor_process(delta: float) -> void:
	cursor.position = lerp(
		cursor.position, 
		color_select_buttons[cursor_index].position, 
		CURSOR_MOVE_RATIO * delta
	)
