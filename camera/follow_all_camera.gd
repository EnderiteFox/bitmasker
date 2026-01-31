class_name FollowAllCamera
extends Camera2D
## A camera that keeps all players on screen


const SCREEN_MARGIN_PERCENTAGE: float = 0.25


func _process(_delta: float) -> void:
	self.global_position = Vector2.ZERO
	var min_pos: Vector2 = Vector2.INF
	var max_pos: Vector2 = -Vector2.INF
	
	# Iterate over players to get the minimum and maximum positions on screen
	for player: PlayerData in Game.players:
		var bitmasker_rect: Rect2 = player.bitmasker.get_camera_rect()
		var has_bitmasker_constraint: bool = bitmasker_rect.size != Vector2.ZERO
	
		self.global_position += player.ship.global_position / Game.players.size()
		min_pos.x = min(min_pos.x, player.ship.global_position.x)
		min_pos.y = min(min_pos.y, player.ship.global_position.y)
		max_pos.x = max(max_pos.x, player.ship.global_position.x)
		max_pos.y = max(max_pos.y, player.ship.global_position.y)
		
		if has_bitmasker_constraint:
			min_pos.x = min(min_pos.x, bitmasker_rect.position.x)
			min_pos.y = min(min_pos.y, bitmasker_rect.position.y)
			max_pos.x = max(max_pos.x, bitmasker_rect.position.x + bitmasker_rect.size.x)
			max_pos.y = max(max_pos.y, bitmasker_rect.position.y + bitmasker_rect.size.y)
		
	# Adjust zoom to keep everything on screen
	var current_viewport_res: Vector2 = get_viewport().get_visible_rect().size
	var screen_margin_vector: Vector2 = current_viewport_res * SCREEN_MARGIN_PERCENTAGE
	var screen_margin: float = max(screen_margin_vector.x, screen_margin_vector.y)
	var target_screen_size: Vector2 = Vector2(
		max_pos.x - min_pos.x + screen_margin * 2,
		max_pos.y - min_pos.y + screen_margin * 2
	)
	
	var zoom_vector: Vector2 = current_viewport_res / target_screen_size
	var zoom_value: float = min(zoom_vector.x, zoom_vector.y)
	
	self.set_zoom(Vector2(zoom_value, zoom_value))
