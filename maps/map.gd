class_name Map
extends Node2D


var spawn_points: Array[Vector2]


func _ready() -> void:
	for child: Node in get_children():
		if child is Marker2D:
			var spawn_point: Marker2D = child
			spawn_points.append(spawn_point.position)
