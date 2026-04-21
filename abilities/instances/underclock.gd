class_name Underclock
extends Ability

const COMPLEXITY : int = -1;

func _ready() -> void:
	self.complexity = COMPLEXITY

func activate() -> void:
	pass


func _on_body_entered_selection(body: Node2D) -> void:
	if body is PlayerShip and activated:
		var ship: PlayerShip = body as PlayerShip
		pass
