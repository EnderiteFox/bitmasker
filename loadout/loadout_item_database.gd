class_name LoadoutItemDatabase
extends Resource


@export var items: Array[LoadoutItem]


func get_from_id(id: StringName) -> LoadoutItem:
	for item: LoadoutItem in items:
		if item.id == id:
			return item
			
	return null
