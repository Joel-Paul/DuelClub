extends Node2D


onready var draw_deck = $DrawDeck
onready var hand = $Hand

var CardBlank := load("res://Cards/CardBlank/CardBlank.tscn")


func _ready() -> void:
	hand.position.x = get_viewport_rect().size.x / 2
	hand.position.y = get_viewport_rect().size.y * 0.95
	
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())
	draw_deck.add_card(CardBlank.instance())


func _on_DrawDeck_card_drawn(card: Card) -> void:
	if (card != null):
		hand.add_card(card, draw_deck.global_position)
