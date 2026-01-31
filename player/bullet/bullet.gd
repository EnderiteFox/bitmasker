class_name Bullet
extends Area2D


const BULLET_SPEED: float = 600


var player: PlayerData


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	self.global_position += Vector2(
		cos(self.global_rotation),
		sin(self.global_rotation)
	) * delta * BULLET_SPEED


func destroy() -> void:
	queue_free()


func set_player(player_data: PlayerData) -> void:
	player = player_data
	self.modulate = player_data.color


func _on_body_entered(body: Node2D) -> void:
	if body != player.ship:
		if body is PlayerShip:
			var player_ship: PlayerShip = body
			player_ship.damage()
		destroy()
