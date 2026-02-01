class_name CircularBitmasker
extends Bitmasker


const CIRCLE_RADIUS: float = 3.5


var cursor: BitmaskCursor = null


func on_select() -> void:
	if not can_start_select():
		return

	if cursor != null:
		cursor.queue_free()
		
	cursor = self.spawn_cursor()
	cursor.moved.connect(_on_cursor_move)
	clear_selection()
	_fill_circ(cursor.tile_position, false)
	
	
func on_unselect() -> void:
	if cursor != null and not selection_complete:
		cursor.queue_free()
		cursor = null
		tilemap_layer.clear()
		
		
func on_confirm() -> void:
	if cursor == null:
		return
	confirm_validation()
		
		
func confirm_validation() -> void:
	super.confirm_validation()
	tilemap_layer.clear()
	_fill_circ(cursor.tile_position, true)
	cursor.queue_free()
	cursor = null
	
	
func get_camera_rect() -> Rect2:
	if cursor == null:
		return Rect2(0, 0, 0, 0)
		
	var cursor_size: Vector2 = tile_to_global(Vector2i(1, 1))
	
	return Rect2(cursor.global_position, cursor_size)
	
	
func get_ship_target_pos() -> Vector2:
	if cursor == null:
		return Vector2.INF
		
	return cursor.global_position - tile_to_global(Vector2i(1, 1)) / 2
	
	
func _on_cursor_move() -> void:
	tilemap_layer.clear()
	_fill_circ(cursor.tile_position, false)
	
	
func _fill_circ(center: Vector2i, final_selection: bool) -> void:
	var radius_x_right: int = center.x + int(CIRCLE_RADIUS) * 2
	var radius_x_left : int = center.x - int(CIRCLE_RADIUS) * 2
	var radius_y_up: int = center.y + int(CIRCLE_RADIUS) * 2
	var radius_y_down: int = center.y - int(CIRCLE_RADIUS) * 2
		
	var cell_type: Vector2i = SELECTION_CELL if final_selection else PREVIEW_CELL
	
	for x: int in range(radius_x_left , radius_x_right):
		for y: int in range(radius_y_down, radius_y_up):
			if center.distance_to(Vector2i(x,y)) <= CIRCLE_RADIUS:
				tilemap_layer.set_cell(Vector2i(x, y), 1, cell_type)
