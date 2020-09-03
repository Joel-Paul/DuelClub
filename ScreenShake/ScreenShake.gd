extends Node
# A simple node that handles screenshake.
# Copied from Game Endevour's video, "How to Screen Shake in Godot 3.0".
# Game Endevour's channel: https://www.youtube.com/c/GameEndeavor/featured
# How to Screen Shake in Godot 3.0: https://youtu.be/_DAvzzJMko8


const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()


func start(amp = 16, dur = 0.2, freq = 15, prior = 0):
	if prior >= priority:
		priority = prior
		amplitude = amp
		
		$DurationTimer.wait_time = dur
		$FrequencyTimer.wait_time = 1 / float(freq)
		$DurationTimer.start()
		$FrequencyTimer.start()
		
		_new_shake()


func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $FrequencyTimer.wait_time, TRANS, EASE)
	$ShakeTween.start()


func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $FrequencyTimer.wait_time, TRANS, EASE)
	$ShakeTween.start()
	priority = 0


func _on_FrequencyTimer_timeout():
	_new_shake()


func _on_DurationTimer_timeout():
	_reset()
	$FrequencyTimer.stop()
