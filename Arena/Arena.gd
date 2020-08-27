extends Node2D


onready var player_deck = $PlayerDeck
onready var hand = $Hand

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var CardFlipendo := load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var CardRictusempra := load("res://Cards/CardRictusempra/CardRictusempra.tscn")

var cards = [CardExpelliarmus, CardFlipendo, CardRictusempra]


func _ready() -> void:
	for _i in range(10):
		cards.shuffle()
		var rand_card = cards.front()
		player_deck.add_card(rand_card.instance())


func _on_DrawDeck_card_drawn(card: Card) -> void:
	if (card != null):
		hand.add_card(card, player_deck.global_position)
	
