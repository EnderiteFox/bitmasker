class_name PlayerShip
extends CharacterBody2D


const ACCELERATION: float = 10
const SPEED: int = 315
const DEAD_ZONE: float = 0.2
const ROTATION_SPEED: float = 0.25


var player: PlayerData


func _physics_process(delta: float) -> void:
	if not player:
		return
		
	var joy: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_Y)
	)
	if joy.length() < 0.3:
		joy = Vector2.ZERO
		
	var target_speed: Vector2 = joy * SPEED
	velocity.x = move_toward(velocity.x, target_speed.x, absf(velocity.x - target_speed.x) * delta * ACCELERATION)
	velocity.y = move_toward(velocity.y, target_speed.y, absf(velocity.y - target_speed.y) * delta * ACCELERATION)
	rotation = lerp_angle(rotation, get_target_rotation(), ROTATION_SPEED)
	
	move_and_slide()


func get_target_rotation() -> float:
	var joy_l: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_Y)
	)
	var joy_r: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_RIGHT_Y)
	)
	
	if joy_r.length() > DEAD_ZONE:
		return joy_r.angle()
	elif joy_l.length() > DEAD_ZONE:
		return joy_l.angle()
		
	return rotation
