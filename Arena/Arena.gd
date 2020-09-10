extends Node


onready var player: Dueler = $DuelerPlayer
onready var enemy: Dueler = $DuelerEnemy

var current_dueler: Dueler


func _ready() -> void:
	print($Camera2D.get_viewport_rect().size) # TODO: Remove when convienient.
	randomize()
	player.opponent = enemy
	enemy.opponent = player
	
	yield(get_tree().create_timer(1), "timeout")
	start_combat()


# Initiate the combat.
func start_combat() -> void:
	current_dueler = player
	update_gui()
	
	# Start off with 3 cards in each hand.
	player.draw_to_hand(3)
	enemy.draw_to_hand(3)
	
	play_turn()


# Combat loop.
func play_turn() -> void:
	current_dueler.play_turn()
	
	# Wait for all animations to finish before proceeding.
	yield(current_dueler, "turn_ended")
	if current_dueler.get_node("Tween").is_active():
		yield(current_dueler.get_node("Tween"), "tween_all_completed")
	
	current_dueler = current_dueler.opponent
	yield(update_gui(), "completed")
	
	play_turn()


# Update GUI button and turn text.
func update_gui() -> void:
	var text := ""
	if current_dueler.is_player:
		text = "Your Turn"
		$GUI.disable_button(false)
	else:
		text = "Enemy's Turn"
		$GUI.disable_button(true)
	
	$GUI.play_turn_label(text)
	yield($GUI/Tween, "tween_all_completed")
