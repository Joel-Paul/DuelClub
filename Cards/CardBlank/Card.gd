class_name Card
extends Node2D


var size setget , get_size
var width setget , get_width
var height setget , get_height

signal focused(card)
signal unfocused

onready var tween = $Tween
onready var default_z_index = z_index
onready var focus_glow = $FocusGlow

func _ready():
	focus_glow.visible = false
	$FocusButton.visible = false


func get_size() -> Vector2:
	return $Background.texture.get_size() * scale


func get_width() -> float:
	return $Background.texture.get_width() * scale.x


func get_height() -> float:
	return $Background.texture.get_height() * scale.y


func tween_to_pos(target_pos: Vector2) -> void:
	tween.interpolate_property(self, "position", position,
			target_pos, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
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
	focus_glow.visible = true
	z_index = 99
	emit_signal("focused", self)


func make_unfocused() -> void:
	focus_glow.visible = false
	z_index = default_z_index
	emit_signal("unfocused")


func _on_Timer_timeout():
	$FocusButton.visible = true
