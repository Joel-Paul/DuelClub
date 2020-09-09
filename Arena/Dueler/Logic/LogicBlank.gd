extends Node2D
# A skeleton script to implement turn logic for the AI or player.


onready var dueler: Dueler = get_parent()
onready var hand: Hand = dueler.get_node("Hand")


func play_turn() -> void:
	yield(get_tree().create_timer(1), "timeout")
