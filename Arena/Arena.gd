tool
extends Node2D


export(float, 1) var play_area = 0.66

onready var player_deck = $PlayerDeck
onready var hand = $Hand

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var CardFlipendo := load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var CardRictusempra := load("res://Cards/CardRictusempra/CardRictusempra.tscn")

var cards = [CardExpelliarmus, CardFlipendo, CardRictusempra]


func _ready() -> void:
	if Engine.editor_hint:
		pass
	else:
		print(get_viewport_rect().size)
		
		hand.position = get_viewport_rect().size * Vector2(0.5, 0.95)
		
		for _i in range(10):
			cards.shuffle()
			var rand_card = cards.front()
			player_deck.add_card(rand_card.instance())


func _draw():
	if Engine.editor_hint:
		var rect = Rect2(Vector2(0, 0), get_viewport_rect().size * Vector2(1, play_area))
		draw_rect(rect, Color.dimgray, true, 1.0)
		

func _process(_delta):
	if Engine.editor_hint:
		update()


func _on_DrawDeck_card_drawn(card: Card) -> void:
	if (card != null):
		hand.add_card(card, player_deck.global_position)
	

func _on_Hand_card_released(card: Card):
	var in_play_area = get_global_mouse_position().y < get_viewport_rect().size.y * play_area
	if in_play_area:
		hand.remove_card(card)
	hand.update_hand()
