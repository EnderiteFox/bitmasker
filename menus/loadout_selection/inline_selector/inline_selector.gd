class_name InlineSelector
extends Control


@export var loadout_item_database: LoadoutItemDatabase


var selected_index: int = 0:
	set(new_index):
		selected_index = new_index % elements.size()
		update_infos()
		
var elements: Array[LoadoutItem]


@onready var ability_texture: TextureRect = %Texture
@onready var ability_name: Label = %AbilityName
@onready var ability_description: Label = %AbilityDescription


func _ready() -> void:
	elements = loadout_item_database.items

	for i: int in range(elements.size()):
		selected_index = i
		self.custom_minimum_size.x = max(self.custom_minimum_size.x, get_minimum_size().x)
		
	selected_index = 0


## Updates the textures and the text of the selector
func update_infos() -> void:
	ability_texture.texture = elements[selected_index].texture
	ability_name.text = elements[selected_index].name
	ability_description.text = elements[selected_index].description
	
	
func get_selected_element() -> LoadoutItem:
	return elements[selected_index]
