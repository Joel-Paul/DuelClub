class_name Card
extends Node2D


var size setget , get_size
var width setget , get_width
var height setget , get_height

signal focused(card)

onready var tween = $Tween


func _ready():
	$FocusGlow.visible = false
	$FocusButton.visible = false


func get_size() -> Vector2:
	return $Background.texture.get_size()


func get_width() -> float:
	return $Background.texture.get_width()


func get_height() -> float:
	return $Background.texture.get_height()


func tween_to_pos(target_pos: Vector2) -> void:
	tween.interpolate_property(self, "position", position,
			target_pos, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func tween_to_rot(target_rot: float) -> void:
	tween.interpolate_property(self, "rotation", rotation,
			target_rot, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func tween_to_scale(target_scale: Vector2) -> void:
	tween.interpolate_property(self, "scale", scale,
			target_scale, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func make_focused() -> void:
	$FocusGlow.visible = true
	emit_signal("focused", self)


func make_unfocused() -> void:
	$FocusGlow.visible = false


func _on_Timer_timeout():
	$FocusButton.visible = true
