class_name Drifter
extends Ability


const DURATION: float = 10
const COMPLEXITY: int = -2


func _ready() -> void:
	self.complexity = COMPLEXITY

func init_ability() -> void:
	super.init_ability()
	bitmasker.body_entered_selection.connect(_on_body_entered_selection)
	bitmasker.body_exited_selection.connect(_on_body_exited_selection)


func activate() -> void:
	activated = true
	get_tree().create_timer(DURATION).timeout.connect(self.deactivate)
	for body: Node2D in bitmasker.bodies_in_selection:
		if body is PlayerShip:
			var ship: PlayerShip = body as PlayerShip
			ship.drift_mode += 1
			
			
func deactivate() -> void:
	for body: Node2D in bitmasker.bodies_in_selection:
		if body is PlayerShip:
			var ship: PlayerShip = body as PlayerShip
			ship.drift_mode -= 1
	super.deactivate()
	
	
func _on_body_entered_selection(body: Node2D) -> void:
	if body is PlayerShip and activated:
		var ship: PlayerShip = body as PlayerShip
		ship.drift_mode += 1
	
	
func _on_body_exited_selection(body: Node2D) -> void:
	if body is PlayerShip and activated:
		var ship: PlayerShip = body as PlayerShip
		ship.drift_mode -= 1
