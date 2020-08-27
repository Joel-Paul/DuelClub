tool
extends Node2D
# Arena for the player and AI to battle.
# Handles the deck and card hand positions of the player 
# and AI, and the logic of the turn-based combat.


# A float between 0-1 describing how far up the screen a card can be "played",
# i.e. a value of 0.5 means if the player lets go of the card in
# the top 50% of the window, the card will be considered played.
export(float, 1) var vert_play_limit = 0.5

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var CardFlipendo := load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var CardRictusempra := load("res://Cards/CardRictusempra/CardRictusempra.tscn")

var cards = [CardExpelliarmus, CardFlipendo, CardRictusempra]

onready var player_deck = $PlayerDeck
onready var hand = $Hand


func _ready() -> void:
	if not Engine.editor_hint:
		print(get_viewport_rect().size) # TODO: Remove when convienient.
		
		hand.position = get_viewport_rect().size * Vector2(0.5, 0.95)
		
		# Add 10 random cards to the deck.
		for _i in range(10):
			cards.shuffle()
			var rand_card = cards.front()
			player_deck.add_card(rand_card.instance())


func _draw() -> void:
	if Engine.editor_hint:
		# Draws a rectangle to visually indicate where cards can be played.
		var size := get_viewport_rect().size * Vector2(1, vert_play_limit)
		draw_rect(Rect2(Vector2(0, 0), size), Color.dimgray, true, 1.0)
		

func _process(_delta) -> void:
	# Update _draw()
	if Engine.editor_hint:
		update()


# Add a card to the player's hand whenever PlayerDeck is clicked.
func _on_PlayerDeck_card_drawn(card: Card) -> void:
	if (card != null):
		hand.add_card(card, player_deck.global_position)
	

# Determine if a card is being played when a card is released.
# If a card is being played, apply all its effects, otherwise do nothing.
func _on_Hand_card_released(card: Card):
	var in_bounds = get_global_mouse_position().y < get_viewport_rect().size.y * vert_play_limit
	if in_bounds:
		hand.remove_card(card)
	hand.update_hand()
