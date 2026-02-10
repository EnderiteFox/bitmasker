class_name HealthBar
extends Node2D


const BACKGROUND_STYLEBOX: StyleBox = preload("uid://dogbts6cjiqes")
const FILL_STYLEBOX: StyleBox = preload("uid://45qgj5mhb0t4")

const OUTLINE_SEPARATION: float = 8
const HEIGHT_RATIO: float = 0.2

const MOVE_FACTOR: float = 4

const FADE_IN_TIME: float = 0.2
const STAY_TIME: float = 1.2
const FADE_OUT_TIME: float = 0.2


var ship: PlayerShip
var current_value: float = 1.0
var tween: Tween = null


func _ready() -> void:
	assert(get_parent() is PlayerShip)
	ship = get_parent()
	ship.damaged.connect(_on_damaged)
	self.modulate = Color.TRANSPARENT
	
	
func _process(delta: float) -> void:
	self.global_position = ship.global_position
	var target_value: float = ship.health / float(PlayerShip.MAX_HEALTH)
	
	if target_value != self.current_value:
		self.queue_redraw()
	
	self.current_value = move_toward(
		self.current_value, 
		target_value, 
		absf(self.current_value - target_value) * MOVE_FACTOR * delta
	)


func _draw() -> void:
	var width: float = ship.sprite.get_rect().size.x
	var outline_size: Vector2 = Vector2(
		width,
		width * HEIGHT_RATIO
	)
	var outline_rect: Rect2 = Rect2(
		Vector2(
			-ship.sprite.get_rect().size.x / 2,
			-ship.sprite.get_rect().size.y / 2 - outline_size.y
		),
		outline_size
	)
	var fill_rect: Rect2 = outline_rect.grow(-OUTLINE_SEPARATION)
	fill_rect.size.x *= self.current_value
	draw_style_box(
		BACKGROUND_STYLEBOX,
		outline_rect
	)
	draw_style_box(
		FILL_STYLEBOX,
		fill_rect
	)
	
	
func _on_damaged() -> void:
	if tween != null:
		tween.kill()
		tween = null

	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_IN_TIME)
	tween.tween_interval(STAY_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_TIME)
	tween.tween_callback(func() -> void: tween = null)
