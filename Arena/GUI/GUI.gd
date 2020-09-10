extends Control


signal turn_ended


func _ready() -> void:
	$TurnPanel.modulate = Color(1, 1, 1, 0)
	$TurnPanel.visible = false


func play_turn_label(text: String = "Click To Add Text") -> void:
	$TurnPanel.visible = true
	$TurnPanel/TurnLabel.text = text
	# Fade in, wait 1 second, then fade out.
	$Tween.interpolate_property($TurnPanel, "modulate", Color(1, 1, 1, 0),
			Color(1, 1, 1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($TurnPanel, "modulate", Color(1, 1, 1, 1),
			Color(1, 1, 1, 0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.2)
	$Tween.start()


func disable_button(value: bool = true) -> void:
	$EndTurnButton.disabled = value


func _on_EndTurnButton_pressed() -> void:
	disable_button(true)
	emit_signal("turn_ended")
