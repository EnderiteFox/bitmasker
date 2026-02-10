class_name RectangularBitmasker
extends Bitmasker
## A bitmasker that selects a rectangular region


const MAX_SIZE: int = 60


## The current cursor
var cursor: BitmaskCursor = null
## The first selected corner of the rectangle
## Vector2i.MAX if the first corner was not selected yet
var selection_start: Vector2i = Vector2i.MAX


func _ready() -> void:
	complexity = -1


func get_max_size() -> float:
	return float(MAX_SIZE + -0.1 * (ability.complexity + self.complexity) * MAX_SIZE)


func on_select() -> void:
	if not can_start_select():
		return

	if cursor != null:
		cursor.queue_free()
		
	cursor = self.spawn_cursor()
	cursor.moved.connect(_on_cursor_move)
	clear_selection()
	
	
func on_unselect() -> void:
	if cursor != null and not selection_complete:
		cursor.queue_free()
		cursor = null
		selection_start = Vector2i.MAX
		tilemap_layer.clear()
		
		
func on_confirm() -> void:
	if cursor == null:
		return

	if selection_start == Vector2i.MAX:
		selection_start = Vector2i(cursor.tile_position)
		_fill_rect(selection_start, cursor.tile_position, false)
	else:
		confirm_validation()
		
		
func confirm_validation() -> void:
	super.confirm_validation()
	tilemap_layer.clear()
	_fill_rect(selection_start, cursor.tile_position, true)
	cursor.queue_free()
	cursor = null
	selection_start = Vector2i.MAX
	
	
func clear_selection() -> void:
	super.clear_selection()
	selection_start = Vector2i.MAX
	
	
func get_camera_rect() -> Rect2:
	if cursor == null:
		return Rect2(0, 0, 0, 0)
		
	var cursor_size: Vector2 = tile_to_global(Vector2i(1, 1))
	
	return Rect2(cursor.global_position, cursor_size)
	
	
func get_ship_target_pos() -> Vector2:
	if cursor == null:
		return Vector2.INF
		
	return cursor.global_position - tile_to_global(Vector2i(1, 1)) / 2
	

## Called when the cursor moves
func _on_cursor_move(old_pos: Vector2i, new_pos: Vector2i) -> void:
	if selection_start != Vector2i.MAX:
		tilemap_layer.clear()
		if (abs(selection_start.x - new_pos.x) + 1) * (abs(selection_start.y - new_pos.y) + 1) >= get_max_size():
			cursor.set_tile_position(old_pos)
		_fill_rect(selection_start, cursor.tile_position, false)
		
	
	
## Fills a rectangle in the selection
## If final_selection is false, fills the selection with preview tiles
func _fill_rect(corner_1: Vector2i, corner_2: Vector2i, final_selection: bool) -> void:
	var min_corner: Vector2i = Vector2i(
		mini(corner_1.x, corner_2.x),
		mini(corner_1.y, corner_2.y)
	)
	var max_corner: Vector2i = Vector2i(
		maxi(corner_1.x, corner_2.x),
		maxi(corner_1.y, corner_2.y)
	)
	
	var cell_type: Vector2i = SELECTION_CELL if final_selection else PREVIEW_CELL
	
	for x: int in range(min_corner.x, max_corner.x + 1):
		for y: int in range(min_corner.y, max_corner.y + 1):
			tilemap_layer.set_cell(Vector2i(x, y), 1, cell_type)
