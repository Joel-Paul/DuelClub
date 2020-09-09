extends "res://Arena/Dueler/Logic/LogicBlank.gd"
# An AI that chooses a random card from its hand to play.


func play_turn() -> void:
	yield(get_tree().create_timer(1), "timeout")
	if hand.cards.empty():
		# Do something???
		pass
	else:
		var chosen_card: Card = hand.cards[randi() % hand.cards.size()]
		dueler.activate_card(chosen_card)
	yield(get_tree().create_timer(3), "timeout")
	dueler.emit_ended_turn()
