class_name SelectionMenu
extends Control


const player_display_scene: PackedScene = preload("uid://csj3ycl753d53")

var player_controllers: Dictionary[int, PlayerDisplay]
var taken_colors: Array[Color]

@onready var player_list_hbox: HBoxContainer = %PlayerList
@onready var ready_button: Button = %ReadyButton


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_controller_connection_state_changed)


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventJoypadButton\
	and input_event.is_pressed()\
	and Input.get_connected_joypads().has(input_event.device)\
	and not player_controllers.has(input_event.device):
		add_player_display(input_event.device)
		return
		
	if input_event.is_action_pressed(&"start") and _can_ready():
		_on_ready()
		
		
func add_player_display(controller_id: int) -> void:
	if player_controllers.size() >= Game.MAX_PLAYERS:
		return
	
	var player_display: PlayerDisplay = player_display_scene.instantiate()
	player_display.controller_id = controller_id
	player_display.taken_colors = taken_colors
	player_list_hbox.add_child(player_display)
	
	player_controllers[controller_id] = player_display
	player_display.update_colors()
	
	player_display.color_selected.connect(_on_color_selected)
	player_display.color_unselected.connect(_on_color_unselected)
	player_display.disconnected.connect(remove_player_display.bind(controller_id))
	
	
func remove_player_display(controller_id: int) -> void:
	player_controllers[controller_id].unselect_color()
	player_controllers[controller_id].color_selected.disconnect(_on_color_selected)
	player_controllers[controller_id].queue_free()
	player_controllers.erase(controller_id)
	
	
func _on_controller_connection_state_changed(controller_id: int, connected: bool) -> void:
	if not connected:
		remove_player_display(controller_id)
	elif Input.has_joy_light(controller_id):
		Input.set_joy_light(controller_id, Color.BLACK)
	
	
func _on_color_selected(color: Color) -> void:
	taken_colors.append(color)

	for player_display: PlayerDisplay in player_controllers.values():
		player_display.update_colors()
		
	_update_ready_button()
	
	
func _on_color_unselected(color: Color) -> void:
	taken_colors.erase(color)

	for player_display: PlayerDisplay in player_controllers.values():
		player_display.update_colors()
		
	_update_ready_button()
	
	
func _can_ready() -> bool:
	return player_controllers.size() > 0\
	and player_controllers.values().all(
		func(player_display: PlayerDisplay) -> bool:
			return player_display.has_selected_color()
	)
	
	
func _update_ready_button() -> void:
	ready_button.disabled = not _can_ready()
	
	
func _on_ready() -> void:
	Game.players.clear()

	for controller_id: int in player_controllers:
		var player_data: PlayerData = PlayerData.new()
		player_data.controller_id = controller_id
		assert(player_controllers[controller_id].selected_color != Color.BLACK)
		player_data.color = player_controllers[controller_id].selected_color
		
		Game.players.append(player_data)

	var pvp_game: PvpGame = PvpGame.new()
	Game.game_instance = pvp_game
	get_tree().change_scene_to_file("uid://j8dg6nfj26yi")
