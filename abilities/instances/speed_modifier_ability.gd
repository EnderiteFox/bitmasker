@abstract class_name SpeedModifierAbility
extends Ability


const DURATION: float = 10


func init_ability() -> void:
	super.init_ability()
	bitmasker.body_entered_selection.connect(_set_modifier.bind(true))
	bitmasker.body_exited_selection.connect(_remove_modifier)


func activate() -> void:
	activated = true
	get_tree().create_timer(DURATION).timeout.connect(self.deactivate)
	for body: Node2D in bitmasker.bodies_in_selection:
		_set_modifier(body, false)
			
			
func deactivate() -> void:
	for body: Node2D in bitmasker.bodies_in_selection:
		_remove_modifier(body)
	super.deactivate()
	
	
@abstract func get_speed_modifier() -> float


func _set_modifier(body: Node2D, requires_activation: bool) -> void:
	if requires_activation and not activated:
		return

	if body is PlayerShip:
		var ship: PlayerShip = body as PlayerShip
		ship.speed_modifier.set_modifier(self, get_speed_modifier())
	elif body is Bullet:
		var bullet: Bullet = body as Bullet
		bullet.speed_modifier.set_modifier(self, get_speed_modifier())
		
		
func _remove_modifier(body: Node2D) -> void:
	if body is PlayerShip:
		var ship: PlayerShip = body as PlayerShip
		ship.speed_modifier.remove_modifier(self)
	elif body is Bullet:
		var bullet: Bullet = body as Bullet
		bullet.speed_modifier.remove_modifier(self)
