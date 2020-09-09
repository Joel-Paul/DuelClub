extends Node2D
# Stores cards in a deck for any general purpose.
# Essentially a glorified array with a TextureButton.


var deck := []


func _ready() -> void:
	z_index = 8
	update_texture()


# Visually updates the card depending on the amount of cards left in the deck.
func update_texture() -> void:
	if (deck.size() > 0):
		$TextureButton.texture_normal = load("res://Cards/CardBlank/back_blank.png")
	else:
		$TextureButton.texture_normal = load("res://Arena/Deck/empty_deck.png")


# Adds a card to the deck.
func add_card_ontop(card: Card) -> void:
	deck.push_back(card)
	update_texture()


# Adds a card to the bottom of the deck.
func add_card_under(card: Card) -> void:
	deck.push_front(card)
	update_texture()


# Removes a card from the top of the deck and returns it.
func draw_card() -> Card:
	var card: Card = deck.pop_back()
	update_texture()
	return card
