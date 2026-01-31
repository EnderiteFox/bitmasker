class_name RectangularBitmasker
extends Bitmasker


var cursor: BitmaskCursor = null


func on_select() -> void:
	if cursor != null:
		cursor.queue_free()
		
	cursor = self.spawn_cursor()
	
	
func on_unselect() -> void:
	if cursor != null:
		cursor.queue_free()
		cursor = null
		
		
func on_confirm() -> void:
	if cursor == null:
		return
		
	(Game.game_instance as PvpGame).map.set_cell(cursor.tile_position)
	
	
func get_camera_rect() -> Rect2:
	if cursor == null:
		return Rect2(0, 0, 0, 0)
		
	var cursor_size: Vector2 = tile_to_global(Vector2i(1, 1))
	
	return Rect2(cursor.global_position, cursor_size)
	
	
func get_ship_target_pos() -> Vector2:
	if cursor == null:
		return Vector2.INF
		
	return cursor.global_position - tile_to_global(Vector2i(1, 1)) / 2
