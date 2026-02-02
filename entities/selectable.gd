@tool
class_name Selectable
extends Area2D
## A component representing an entity that is selectionnable by a bitmask


@export var main_body: Node2D:
	set(new_main_body):
		if main_body != new_main_body:
			main_body = new_main_body
			update_configuration_warnings()


func _ready() -> void:
	if not Engine.is_editor_hint():
		self.body_entered.connect(_on_body_entered)
		self.body_exited.connect(_on_body_exited)
	
	self.collision_layer = 0
	self.collision_mask = 2
	self.input_pickable = false
	
	self.position = Vector2.ZERO
	self.rotation = 0
	self.scale = Vector2.ONE


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		Game.process_selection_entered(main_body, body as TileMapLayer)
		
		
func _on_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		Game.process_selection_exited(main_body, body as TileMapLayer)
		
		
func _get_configuration_warnings() -> PackedStringArray:
	if main_body == null:
		return ["The main body can't be empty"]
		
	return []
