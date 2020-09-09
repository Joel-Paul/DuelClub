extends Control


signal turn_ended


func disable_button(value: bool = true) -> void:
	$EndTurnButton.disabled = value


func _on_EndTurnButton_pressed() -> void:
	emit_signal("turn_ended")
