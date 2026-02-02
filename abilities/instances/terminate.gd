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
			for body: Node2D in bitmasker.bodies_in_selection:
				if body is PlayerShip:
					var ship: PlayerShip = body as PlayerShip
					ship.damage()
					
				if body is Bullet:
					var bullet: Bullet = body as Bullet
					bullet.destroy()
				
			activated = false
			bitmasker.clear_selection()
			bitmasker.tilemap_layer.modulate = player.color
			
			get_tree().create_timer(AFTER_ABILITY_COOLDOWN).timeout.connect(
				func() -> void:
					bitmasker.can_select = true
			)
	)
