class_name PlayerShip
extends CharacterBody2D

signal damaged
signal destroyed

signal entered_selection(tilemap: TileMapLayer)
signal exited_selection(tilemap: TileMapLayer)


const ACCELERATION: float = 10
const SPEED: int = 350
const DEAD_ZONE: float = 0.2
const ROTATION_SPEED: float = 0.25
const SHOOT_COOLDOWN: float = 0.15
const MAX_HEALTH: int = 5
const INVISIBILITY_TIME: float = 1
const HIT_ANIM_LOOP: int = 3

const bullet_scene: PackedScene = preload("uid://02qbedb2v4ag")


var player: PlayerData
var shoot_delay: float = 0
var health: int = MAX_HEALTH

@onready var bullet_origin: Node2D = %BulletOrigin
@onready var timer: Timer = $Timer
@onready var tilemap_detector: Area2D = %TilemapDetector


func _ready() -> void:
	damaged.connect(_on_damaged)
	tilemap_detector.body_entered.connect(_on_body_entered)
	tilemap_detector.body_exited.connect(_on_body_exited)


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
	
	if shoot_delay > 0:
		shoot_delay -= delta
	
	move_and_slide()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton or event.device != player.controller_id:
		return
		
	if event.is_action_pressed(&"attack"):
		shoot()


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
		timer.start()
		if health == 0:
			destroyed.emit()
	
	
func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		entered_selection.emit(body)
	
	
func _on_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		exited_selection.emit(body)
