class_name Map
extends TileMapLayer


## All possible spawn points for the players
## Initialized with Marker2Ds in the map
var spawn_points: Array[Vector2]


func _ready() -> void:
	for child: Node in get_children():
		if child is Marker2D:
			var spawn_point: Marker2D = child
			spawn_points.append(spawn_point.position)
