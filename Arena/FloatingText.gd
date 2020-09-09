extends Position2D
# Creates floating text.
# Big thanks to 'johnygossdev'!
# His channel is here: https://youtu.be/uE4BIZ85Y9w

var text setget set_text

var velocity := Vector2(50, -100)
var gravity = Vector2(0, 2)
var mass = 200


func _ready() -> void:
	# Fade out.
	$Tween.interpolate_property(self, "modulate", modulate, Color(1, 1, 1, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.7)
	# Scale text.
	$Tween.interpolate_property(self, "scale", Vector2(0, 0), Vector2(1, 1), 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0.4, 0.4), 1.0, Tween.TRANS_QUART, Tween.EASE_OUT, 0.6)
	
	$Tween.start()


func _process(delta):
	velocity += gravity * mass * delta
	position += velocity * delta


func set_text(float_text: String) -> void:
	$Label.text = float_text


func _on_Tween_tween_all_completed() -> void:
	self.queue_free()
