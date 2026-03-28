class_name AbilityParticle
extends Sprite2D

enum ActivationType {
	PRESELECTION,
	SELECTED,
	ACTIVE
}

const SIZE: float = 0.5
const SPEED: float = 20
const FADE_IN: float = 0.4
const STAY_TIME: float = 0.6
const FADE_OUT: float = 0.4

const PRESELECTION_TRANSPARENCY: float = 0.25
const SELECTED_TRANSPARENCY: float = 0.4
const ACTIVE_TRANSPARENCY: float = 1.0


var velocity: Vector2 = Vector2.ZERO
var target_transparency: float


func _process(delta: float) -> void:
	self.global_position += velocity * delta


func init(ability_texture: Texture2D, player_color: Color, activation_type: ActivationType) -> void:
	velocity = Vector2(randf_range(-1, 1) * SPEED, randf_range(-1, 1) * SPEED)
	
	self.texture = ability_texture
	self.modulate = player_color
	self.scale = Vector2(SIZE, SIZE)
	
	match activation_type:
		ActivationType.PRESELECTION:
			target_transparency = PRESELECTION_TRANSPARENCY
		ActivationType.SELECTED:
			target_transparency = SELECTED_TRANSPARENCY
		ActivationType.ACTIVE:
			target_transparency = ACTIVE_TRANSPARENCY
			
	self.modulate.a = 0
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate:a", target_transparency, FADE_IN)
	tween.tween_interval(STAY_TIME)
	tween.tween_property(self, "modulate:a", 0, FADE_OUT)
	tween.tween_callback(self.queue_free)
