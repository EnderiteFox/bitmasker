class_name Terminate
extends Ability


const BLINKS: int = 3
const GRACE_PERIOD: float = 1
const WARNING_COLOR: Color = Color.DARK_RED


func activate() -> void:
	activated = true

	var blink_interval: float = GRACE_PERIOD / (2 * BLINKS)
	var tween: Tween = get_tree().create_tween()
	for i: int in range(BLINKS):
		tween.tween_callback(
			func() -> void:
				bitmasker.tilemap_layer.modulate = WARNING_COLOR
		)
		tween.tween_interval(blink_interval)
		tween.tween_callback(
			func() -> void:
				bitmasker.tilemap_layer.modulate = player.color
		)
		tween.tween_interval(blink_interval)
	tween.tween_callback(
		func() -> void:
			for other_player: PlayerData in bitmasker.players_in_selection:
				other_player.ship.damage()
				
			activated = false
			bitmasker.clear_selection()
			bitmasker.tilemap_layer.modulate = player.color
	)
