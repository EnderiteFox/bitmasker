extends Control


const loadout_selector_scene: PackedScene = preload("uid://csjyhp5u56bax")


var selectors: Array[PlayerLoadoutSelector]


@onready var loadout_selectors: Control = %PlayerSelectors
@onready var ready_button: Button = %ReadyButton


func _ready() -> void:
	for player: PlayerData in Game.players:
		var loadout_selector: PlayerLoadoutSelector = loadout_selector_scene.instantiate()
		loadout_selector.player = player
		loadout_selectors.add_child(loadout_selector)
		selectors.append(loadout_selector)
	
	for selector: PlayerLoadoutSelector in selectors:
		selector.init_cursor.call_deferred.call_deferred()
		
		
func _process(_delta: float) -> void:
	ready_button.disabled = not _can_ready()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start") and _can_ready():
		_on_start()
		
		
func _can_ready() -> bool:
	return selectors.all(
		func(selector: PlayerLoadoutSelector) -> bool:
			return selector.bitmasker_selected and selector.ability_selected
	)
	
	
func _on_start() -> void:
	for selector: PlayerLoadoutSelector in selectors:
		selector.confirm_loadout()
		
	get_tree().change_scene_to_file("uid://j8dg6nfj26yi")
