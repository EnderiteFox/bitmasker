class_name MainMenu
extends Control


const COLOR_SELECTION_SCENE: PackedScene = preload("uid://ddtgh0dts4fgf")


const GAME_OPENED_ANIMATION: StringName = &"game_opened"
const AFTER_OPENING_ANIMATION: StringName = &"after_opening"

const MIN_FLICKER: float = 0.5
const MAX_FLICKER: float = 1.0
const MIN_FLICKER_INTERVAL: float = 0.1
const MAX_FLICKER_INTERVAL: float = 0.2


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var play_button: Button = %PlayButton


func _ready() -> void:
	animation_player.play(GAME_OPENED_ANIMATION)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"confirm"):
		get_tree().change_scene_to_packed(COLOR_SELECTION_SCENE)
	
	
func _on_animation_finished(anim: StringName) -> void:
	match anim:
		GAME_OPENED_ANIMATION:
			animation_player.play(AFTER_OPENING_ANIMATION)
