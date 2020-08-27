extends Node2D
# Stores cards in a deck for any general purpose.
# Essentially a glorified array with a TextureButton.


signal card_drawn(card)
var deck := []


func _ready() -> void:
	update_texture()


# Visually updates the card depending on the amount of cards left in the deck.
func update_texture() -> void:
	if (deck.size() > 0):
		$TextureButton.texture_normal = load("res://Deck/filled_deck.png")
	else:
		$TextureButton.texture_normal = load("res://Deck/empty_deck.png")


# Add a card to the deck.
func add_card(card: Card) -> void:
	deck.append(card)
	update_texture()


# Removes a card from the top of the deck and returns it.
func draw_card() -> Card:
	var card: Card = deck.pop_back()
	update_texture()
	return card


# When the deck is clicked, draw a card and send it with a signal.
func _on_TextureButton_pressed() -> void:
	emit_signal("card_drawn", draw_card())
