tool
class_name Card
extends Node2D
# A playing card for a card game :O.
# Stores all the properties of the card within itself.


signal focused(card)
signal unfocused
signal pressed(card)
signal released(card)

export(String) var title = "[Title]"
export(String, MULTILINE) var description = "[Description]"
export(int) var cost = 0
export(Global.Stance) var stance = Global.Stance.NONE
export(Array, Resource) var effects

var size setget , get_size
var width setget , get_width
var height setget , get_height

onready var tween = $Tween
onready var default_z_index = z_index
onready var focus_glow = $FocusGlow


func _ready():
	focus_glow.visible = false
	$CardButton.visible = false
	
	$Title/Label.text = title
	$Description/RichTextLabel.text = description
	$Cost/Label.text = String(cost)


func _process(_delta):
	if Engine.editor_hint:
		# Update the card visually.
		$Title/Label.text = title
		$Description/RichTextLabel.text = description
		$Cost/Label.text = String(cost)


func get_size() -> Vector2:
	return $Background.texture.get_size() * scale


func get_width() -> float:
	return $Background.texture.get_width() * scale.x


func get_height() -> float:
	return $Background.texture.get_height() * scale.y


# Removes the card from memory.
func kill() -> void:
	queue_free()


# Adds a glow behind the card when hovered over and brings it to the front.
func make_focused() -> void:
	focus_glow.visible = true
	z_index = 32
	emit_signal("focused", self)


# Returns the card to its original state prior to hover over.
func make_unfocused() -> void:
	focus_glow.visible = false
	z_index = default_z_index
	emit_signal("unfocused")


# Enabled the card to be selected after a brief period.
func _on_Timer_timeout():
	$CardButton.visible = true


func _on_CardButton_pressed():
	emit_signal("pressed", self)


func _on_CardButton_button_up():
	emit_signal("released", self)
