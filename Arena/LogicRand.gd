extends "res://Arena/Dueler/Logic/LogicBlank.gd"
# An AI that chooses a random card from its hand to play.


func play_turn() -> void:
	yield(get_tree().create_timer(0.5), "timeout")
	if hand.cards.empty():
		# Do something???
		pass
	else:
		# Choose a random card to play.
		var chosen_card: Card = hand.cards[randi() % hand.cards.size()]
		dueler.activate_card(chosen_card)
	
	# Wait for the cards to return.
	if (dueler.get_node("ReturnTimer").time_left > 0):
		yield(dueler.get_node("ReturnTimer"), "timeout")
	dueler.emit_ended_turn()
