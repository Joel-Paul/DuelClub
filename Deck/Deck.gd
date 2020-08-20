extends Node2D


signal card_drawn(card)

var deck := []


func _ready() -> void:
	update_texture()


func update_texture() -> void:
	if (deck.size() > 0):
		$TextureButton.texture_normal = load("res://Deck/filled_deck.png")
	else:
		$TextureButton.texture_normal = load("res://Deck/empty_deck.png")


func add_card(card: Card) -> void:
	deck.append(card)
	update_texture()


func draw_card() -> Card:
	var card: Card = deck.pop_back()
	update_texture()
	return card


func _on_TextureButton_pressed() -> void:
	emit_signal("card_drawn", draw_card())
