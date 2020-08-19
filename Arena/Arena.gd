extends Node2D


onready var draw_deck = $DrawDeck
onready var hand = $Hand

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")


func _ready() -> void:
	hand.position = get_viewport_rect().size / 2
	
	draw_deck.add_card(CardExpelliarmus.instance())
	draw_deck.add_card(CardExpelliarmus.instance())
	draw_deck.add_card(CardExpelliarmus.instance())
	draw_deck.add_card(CardExpelliarmus.instance())
	draw_deck.add_card(CardExpelliarmus.instance())


func _on_DrawDeck_card_drawn(card: Card) -> void:
	if (card != null):
		card.global_position = draw_deck.global_position
		hand.add_card(card)
		
