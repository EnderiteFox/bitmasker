class_name PlayerShip
extends CharacterBody2D

signal damaged
signal destroyed


const ACCELERATION: float = 10
const BASE_SPEED: int = 375
const DEAD_ZONE: float = 0.2
const ROTATION_SPEED: float = 0.25
const SHOOT_COOLDOWN: float = 0.15
const MAX_HEALTH: int = 5
const INVISIBILITY_TIME: float = 1
const HIT_ANIM_LOOP: int = 3
const MOVEMENT_CANCEL_THRESHOLD: float = 0.01
const HIT_SPEED_BUFF: int = 300

const DRIFT_ACCELERATION: float = 600

var bullet_scene: PackedScene = load("uid://02qbedb2v4ag")

var speed: int = BASE_SPEED
var player: PlayerData
var shoot_delay: float = 0
var health: int = MAX_HEALTH
var drift_mode: int = 0
var last_position: Vector2
var hit_timer: SceneTreeTimer = null


@onready var bullet_origin: Node2D = %BulletOrigin
@onready var timer: Timer = %Timer
@onready var sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	damaged.connect(_on_damaged)
	timer.connect("timeout", timeout)
	self.last_position = self.global_position

func _physics_process(delta: float) -> void:
	if not player:
		return
		
	var joy: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_Y)
	)
	if joy.length() < 0.3:
		joy = Vector2.ZERO
		
	var target_speed: Vector2 = joy * speed
	
	# If we are blocked by a wall, set velocity in that direction to 0
	if abs(self.last_position.x - self.global_position.x) < MOVEMENT_CANCEL_THRESHOLD:
		velocity.x = 0
	if abs(self.last_position.y - self.global_position.y) < MOVEMENT_CANCEL_THRESHOLD:
		velocity.y = 0
	
	var new_velocity: Vector2 = Vector2(velocity)
	
	if drift_mode:
		new_velocity.x += joy.x * delta * (DRIFT_ACCELERATION / drift_mode)
		new_velocity.x = clamp(new_velocity.x, -speed, speed)
		new_velocity.y += joy.y * delta * (DRIFT_ACCELERATION / drift_mode)
		new_velocity.y = clamp(new_velocity.y, -speed, speed)
	else:
		new_velocity.x = move_toward(velocity.x, target_speed.x, absf(velocity.x - target_speed.x) * delta * ACCELERATION)
		new_velocity.y = move_toward(velocity.y, target_speed.y, absf(velocity.y - target_speed.y) * delta * ACCELERATION)
		
	velocity = new_velocity
	
	# Lerp rotation
	rotation = lerp_angle(rotation, get_target_rotation(), ROTATION_SPEED)
	
	# Deplete shoot cooldown
	if shoot_delay > 0:
		shoot_delay -= delta
	
	# Update position
	self.last_position = self.global_position
	move_and_slide()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton or event.device != player.controller_id:
		return
		
	if event.is_action_pressed(&"attack"):
		shoot()
		
	
func _get_validation_conditions() -> Array[ValidationCondition]:
	return [
		ValidationCondition.is_scene_of_type(bullet_scene, Bullet)
	]


## Returns the direction the ship is aiming at
func get_target_rotation() -> float:
	var joy_l: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_LEFT_Y)
	)
	var joy_r: Vector2 = Vector2(
		Input.get_joy_axis(player.controller_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(player.controller_id, JOY_AXIS_RIGHT_Y)
	)
	
	var bitmasker_target_pos: Vector2 = player.bitmasker.get_ship_target_pos()
	
	if bitmasker_target_pos != Vector2.INF:
		var relative_pos: Vector2 = bitmasker_target_pos - self.global_position
		return relative_pos.angle()
	if joy_r.length() > DEAD_ZONE:
		return joy_r.angle()
	elif joy_l.length() > DEAD_ZONE:
		return joy_l.angle()
		
	return rotation
	

## Initializes the ship with a player
func set_player(player_data: PlayerData) -> void:
	self.modulate = player_data.color
	self.player = player_data
	
	
func shoot() -> void:
	if shoot_delay > 0:
		return
		
	shoot_delay = SHOOT_COOLDOWN

	var bullet: Bullet = bullet_scene.instantiate()
	self.add_sibling(bullet)
	bullet.global_position = bullet_origin.global_position
	bullet.global_rotation = self.global_rotation
	bullet.set_player(self.player)


## Damages the ship
func damage() -> void:
	damaged.emit()


## Called when the ship is damaged
func _on_damaged() -> void:
	if timer.is_stopped():
		var damage_tween: Tween = get_tree().create_tween()
		damage_tween.set_loops(HIT_ANIM_LOOP)
		damage_tween.tween_property(self, "modulate", Color.DARK_RED, INVISIBILITY_TIME / (HIT_ANIM_LOOP * 2))
		damage_tween.tween_property(self, "modulate", player.color, INVISIBILITY_TIME / (HIT_ANIM_LOOP * 2))
		health -= 1
		speed = HIT_SPEED_BUFF + BASE_SPEED
		timer.start()
		if health == 0:
			destroyed.emit()


func timeout() -> void:
	speed = BASE_SPEED
