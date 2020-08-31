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
export(Array, Resource) var abilities

var size setget , get_size
var width setget , get_width
var height setget , get_height

onready var default_z_index = z_index


func _ready():
	update_text()
	show_back()
	disable()
	$CardButton.modulate.a = 0


func _process(_delta):
	if Engine.editor_hint:
		show_front()
		update_text()


func get_size() -> Vector2:
	return $Background.texture.get_size() * scale


func get_width() -> float:
	return $Background.texture.get_width() * scale.x


func get_height() -> float:
	return $Background.texture.get_height() * scale.y


# Resets the card's timer.
func reset_timer() -> void:
	$DisabledTimer.autostart = true


# Prevents the timer from triggering.
func disable_timer() -> void:
	$DisabledTimer.stop()


# Prevents the card from being interactable.
func disable() -> void:
	$FocusGlow.visible = false
	$CardButton.visible = false


# Shows the back of the card.
func show_back() -> void:
	$CardBack.visible = true
	$Cost.visible = false


func show_front() -> void:
	$CardBack.visible = false
	$Cost.visible = true


# Updates the text on the card.
func update_text() -> void:
	$Title/Label.text = title
	$Cost/Label.text = String(cost)
	
	# Automatically insert correct stats for the description.
	var desc_formated = description
	for ability in abilities:
		match ability.type:
			Global.Ability.DAMAGE:
				desc_formated = desc_formated.format({"dmg": ability.value})
	$Description/RichTextLabel.bbcode_text = desc_formated


# Adds a glow behind the card when hovered over and emit a signal.
func make_focused() -> void:
	$FocusGlow.visible = true
	emit_signal("focused", self)


# Returns the card to its original state prior to hover over.
func make_unfocused() -> void:
	$FocusGlow.visible = false
	z_index = default_z_index
	emit_signal("unfocused")


# Enabled the card to be selected after a brief period.
func _on_Timer_timeout():
	$CardButton.visible = true


func _on_CardButton_pressed():
	emit_signal("pressed", self)


func _on_CardButton_button_up():
	emit_signal("released", self)
