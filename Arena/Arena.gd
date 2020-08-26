extends Node2D


onready var draw_deck = $DrawDeck
onready var hand = $Hand

var CardBlank := load("res://Cards/CardBlank/CardBlank.tscn")


func _ready() -> void:
	for i in range(10):
		draw_deck.add_card(CardBlank.instance())


func _on_DrawDeck_card_drawn(card: Card) -> void:
	if (card != null):
		hand.add_card(card, draw_deck.global_position)
	
