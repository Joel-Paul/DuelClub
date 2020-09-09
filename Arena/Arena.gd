extends Node


onready var player: Dueler = $DuelerPlayer
onready var enemy: Dueler = $DuelerEnemy

var current_dueler: Dueler


func _ready() -> void:
	print($Camera2D.get_viewport_rect().size) # TODO: Remove when convienient.
	randomize()
	player.opponent = enemy
	enemy.opponent = player
	
	start_combat()


func start_combat() -> void:
	current_dueler = player
	# Start off with 3 cards in each hand.
	yield(get_tree().create_timer(1), "timeout")
	player.draw_to_hand(3)
	enemy.draw_to_hand(3)
	
	play_turn()


func play_turn() -> void:
	print(current_dueler.dueler_name + "'s turn!")
	
	if current_dueler.is_player:
		$GUI.disable_button(false)
	else:
		$GUI.disable_button(true)
	
	current_dueler.play_turn()
	yield(current_dueler, "turn_ended")
	
	current_dueler = current_dueler.opponent
	play_turn()
