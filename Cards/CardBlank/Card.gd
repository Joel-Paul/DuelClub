class_name Card
extends Node2D


var size setget , get_size
var width setget , get_width
var height setget , get_height


func get_size() -> Vector2:
	return $CollisionShape2D.shape.extents * 2


func get_width() -> float:
	return $CollisionShape2D.shape.extents.x * 2


func get_height() -> float:
	return $CollisionShape2D.shape.extents.y * 2
