class_name BitmaskCursor
extends Sprite2D
## A cursor used to select a tile


## Emitted when the cursor moves
signal moved(old_pos: Vector2i, new_pos: Vector2i)


const POSITION_EASING: float = 10
const DEAD_ZONE: float = 0.35
## The time interval between two moves of the cursor
const MOVEMENT_INTERVAL: float = 0.1


var bitmasker: Bitmasker
var tile_position: Vector2i:
	set = set_tile_position
var target_position: Vector2
var can_move: bool = true


func _process(delta: float) -> void:
	if bitmasker == null:
		return

	self.global_position.x = move_toward(
		self.global_position.x, 
		self.target_position.x, 
		absf(self.global_position.x - self.target_position.x) * POSITION_EASING * delta
	)
	self.global_position.y = move_toward(
		self.global_position.y, 
		self.target_position.y, 
		absf(self.global_position.y - self.target_position.y) * POSITION_EASING * delta
	)
	
	if can_move:
		var joy_x: float = Input.get_joy_axis(bitmasker.player.controller_id, JOY_AXIS_RIGHT_X)
		var joy_y: float = Input.get_joy_axis(bitmasker.player.controller_id, JOY_AXIS_RIGHT_Y)
		
		var movement_vector: Vector2i
		
		var old_pos: Vector2i = tile_position

		
		if joy_x > DEAD_ZONE:
			movement_vector.x = 1
		elif joy_x < -DEAD_ZONE:
			movement_vector.x = -1
			
		if joy_y > DEAD_ZONE:
			movement_vector.y = 1
		elif joy_y < -DEAD_ZONE:
			movement_vector.y = -1
			
		set_tile_position(tile_position + movement_vector)
		
		if movement_vector != Vector2i.ZERO:
			can_move = false
			get_tree().create_timer(MOVEMENT_INTERVAL).timeout.connect(
				func() -> void:
					can_move = true
			)
			moved.emit(old_pos, tile_position)


## Sets the tile position of the cursor
func set_tile_position(new_pos: Vector2i) -> void:
	tile_position = new_pos
	self.target_position = bitmasker.tile_to_global(new_pos)
	
	
## Sets the tile position of the cursor without animation
func set_tile_position_instant(new_pos: Vector2i) -> void:
	set_tile_position(new_pos)
	self.global_position = bitmasker.tile_to_global(new_pos)
