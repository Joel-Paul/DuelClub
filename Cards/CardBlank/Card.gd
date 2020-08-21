class_name Card
extends Node2D


var size setget , get_size
var width setget , get_width
var height setget , get_height

const SCALE_DEFAULT = Vector2(0.75, 0.75)


func _ready():
	$FocusGlow.visible = false


func get_size() -> Vector2:
	return $BackgroundButton.texture_normal.get_size()


func get_width() -> float:
	return $BackgroundButton.texture_normal.get_width()


func get_height() -> float:
	return $BackgroundButton.texture_normal.get_height()


func tween_to(target_pos: Vector2) -> void:
	pass


func make_focused():
	$FocusGlow.visible = true


func make_unfocused():
	$FocusGlow.visible = false


func _on_BackgroundButton_mouse_entered():
	make_focused()


func _on_BackgroundButton_mouse_exited():
	make_unfocused()
