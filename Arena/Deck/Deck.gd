tool
extends Node2D
# Stores cards in a deck for any general purpose.
# Essentially a glorified array with a TextureButton.

export(Texture) var texture
var deck := []


func _ready() -> void:
	$Sprite.texture = texture
	if not Engine.editor_hint:
		z_index = 8
		update_deck()


# Visually updates the card depending on the amount of cards left in the deck.
func update_deck() -> void:
	$Sprite/Label.text = str(deck.size())


# Adds a card to the deck.
func add_card_ontop(card: Card) -> void:
	deck.push_back(card)
	update_deck()


# Adds a card to the bottom of the deck.
func add_card_under(card: Card) -> void:
	deck.push_front(card)
	update_deck()


# Removes a card from the top of the deck and returns it.
func draw_card() -> Card:
	var card: Card = deck.pop_back()
	update_deck()
	return card
