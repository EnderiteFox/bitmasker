class_name SelectionMenu
extends Control


const player_display_scene: PackedScene = preload("uid://csj3ycl753d53")
const loadout_menu_scene: PackedScene = preload("uid://ch2bfun51clpe")

var player_controllers: Dictionary[int, PlayerDisplay]
var taken_colors: Array[Color]

@onready var player_list_hbox: HBoxContainer = %PlayerList
@onready var ready_button: Button = %ReadyButton


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_controller_connection_state_changed)
	
	for player: PlayerData in Game.players:
		add_player_display(player.controller_id, player)
		
	for player_display: PlayerDisplay in player_controllers.values():
		player_display.update_colors()
		
	_update_ready_button()


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventJoypadButton\
	and input_event.is_pressed()\
	and Input.get_connected_joypads().has(input_event.device)\
	and not player_controllers.has(input_event.device):
		add_player_display(input_event.device)
		return
		
	if input_event.is_action_pressed(&"start") and _can_ready():
		_on_ready()
		
		
## Adds a player display
func add_player_display(controller_id: int, player: PlayerData = null) -> void:
	if player_controllers.size() >= Game.MAX_PLAYERS:
		return
	
	var player_display: PlayerDisplay = player_display_scene.instantiate()
	player_display.controller_id = controller_id
	player_display.taken_colors = taken_colors
	player_display.player = player
	player_list_hbox.add_child(player_display)
	
	player_controllers[controller_id] = player_display
	if player != null:
		player_display.select_color(player.color)
		taken_colors.append(player.color)
	player_display.update_colors()
	
	player_display.color_selected.connect(_on_color_selected)
	player_display.color_unselected.connect(_on_color_unselected)
	player_display.disconnected.connect(remove_player_display.bind(controller_id))
	
	
## Removes a player display
func remove_player_display(controller_id: int) -> void:
	if not player_controllers.has(controller_id):
		return

	player_controllers[controller_id].unselect_color()
	player_controllers[controller_id].color_selected.disconnect(_on_color_selected)
	player_controllers[controller_id].queue_free()
	player_controllers.erase(controller_id)
	
	
## Called when a controller connects or disconnects
func _on_controller_connection_state_changed(controller_id: int, connected: bool) -> void:
	if not connected:
		remove_player_display(controller_id)
	elif Input.has_joy_light(controller_id):
		Input.set_joy_light(controller_id, Color.BLACK)
	
	
## Called when a player selects their color
func _on_color_selected(color: Color) -> void:
	taken_colors.append(color)

	for player_display: PlayerDisplay in player_controllers.values():
		player_display.update_colors()
		
	_update_ready_button()
	
	
## Called when a player unselects their color
func _on_color_unselected(color: Color) -> void:
	taken_colors.erase(color)

	for player_display: PlayerDisplay in player_controllers.values():
		player_display.update_colors()
		
	_update_ready_button()
	

## Returns true if all players are ready
func _can_ready() -> bool:
	return player_controllers.size() > 1\
	and player_controllers.values().all(
		func(player_display: PlayerDisplay) -> bool:
			return player_display.has_selected_color()
	)
	
	
## Updates the ready button
func _update_ready_button() -> void:
	ready_button.disabled = not _can_ready()
	
	
## Called when the ready button is pressed
func _on_ready() -> void:
	for controller_id: int in player_controllers:
		var player_display: PlayerDisplay = player_controllers[controller_id]
		
		var player_data: PlayerData
		if player_display.player == null:
			player_data = PlayerData.new()
			player_data.controller_id = controller_id
			Game.players.append(player_data)
		else:
			player_data = player_display.player
		
		assert(player_display.selected_color != Color.BLACK)
		player_data.color = player_display.selected_color

	var pvp_game: PvpGame = PvpGame.new()
	Game.game_instance = pvp_game
	get_tree().change_scene_to_packed(loadout_menu_scene)
