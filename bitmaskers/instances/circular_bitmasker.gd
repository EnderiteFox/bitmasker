class_name CircularBitmasker
extends Bitmasker


const CIRCLE_RADIUS: float = 4


var cursor: BitmaskCursor = null


func get_circle_radius() -> float:
	return CIRCLE_RADIUS + -0.1 * (ability.complexity + self.complexity) * CIRCLE_RADIUS


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
	var tilemap_rect: Rect2 = tilemap_layer.get_used_rect()
	return Rect2(
		tile_to_global(tilemap_rect.position),
		tile_to_global(tilemap_rect.size)
	)
	
	
func get_ship_target_pos() -> Vector2:
	if cursor == null:
		return Vector2.INF
		
	return cursor.global_position - tile_to_global(Vector2i(1, 1)) / 2
	
	
func _on_cursor_move(_old_pos: Vector2i, new_pos: Vector2i) -> void:
	tilemap_layer.clear()
	_fill_circ(new_pos, false)
	
	
func _fill_circ(center: Vector2i, final_selection: bool) -> void:
	var radius_x_right: int = center.x + int(get_circle_radius()) * 2
	var radius_x_left : int = center.x - int(get_circle_radius()) * 2
	var radius_y_up: int = center.y + int(get_circle_radius()) * 2
	var radius_y_down: int = center.y - int(get_circle_radius()) * 2
		
	var cell_type: Vector2i = SELECTION_CELL if final_selection else PREVIEW_CELL
	
	for x: int in range(radius_x_left , radius_x_right):
		for y: int in range(radius_y_down, radius_y_up):
			if center.distance_to(Vector2i(x,y)) <= get_circle_radius():
				tilemap_layer.set_cell(Vector2i(x, y), 1, cell_type)
