extends Node


func _ready() -> void:
	self.add_child(Game.game_instance)
	Game.start_game()
