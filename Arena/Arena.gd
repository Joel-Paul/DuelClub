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
var queue_return = []
var queue_delete = []


func _ready() -> void:
	if not Engine.editor_hint:
		print(get_viewport_rect().size) # TODO: Remove when convienient.
		
		$Hand.position = get_viewport_rect().size * Vector2(0.5, 0.95)
		$Hand/Tween.connect("tween_all_completed", self, "delete_returned_cards")
		
		# Add 10 random cards to the deck.
		for _i in range(10):
			cards.shuffle()
			var rand_card = cards.front()
			$PlayerDeck.add_card_ontop(rand_card.instance())


func _draw() -> void:
	if Engine.editor_hint:
		# Draws a rectangle to visually indicate where cards can be played.
		var size := get_viewport_rect().size * Vector2(1, vert_play_limit)
		draw_rect(Rect2(Vector2(0, 0), size), Color.dimgray, true, 1.0)
		

func _process(_delta) -> void:
	# Update _draw()
	if Engine.editor_hint:
		update()


# Activate the given card's abilities.
func activate_card(card: Card) -> void:
	for ability in card.abilities:
		match ability.type:
			Global.Ability.RETURN:
				return_to_deck(card)
			_:
				print("Invalid Ability!")


# Tweens the card to the middle of the screen, then after
# the timer has timeed out, tweens the card back to the
# deck, adds a copy of it to the deck, then frees it.
func return_to_deck(card: Card) -> void:
	# If a previous card is still waiting, skip its time.
	if ($CardReturnTimer.time_left != 0):
		_on_CardReturnTimer_timeout()
	# Disconnect card from hand.
	card.position = card.global_position
	card.get_parent().remove_child(card)
	$Cards.add_child(card)
	card.z_index = -1
	$Hand.update_hand()
	# Move card to middle of screen.
	$Hand.scale_card(card, $Hand.SCALE_FOCUS)
	$Hand.rotate_card(card, 0)
	$Hand.move_card(card, get_viewport_rect().size / 2)
	# Queue for it to move to the deck.
	queue_return.append(card)
	$CardReturnTimer.start()


# Called whenever $Hand/Tween completes all tweens.
func delete_returned_cards() -> void:
	for item in queue_delete:
		for card in $Cards.get_children():
			if (item == card):
				card.queue_free()


# Add a card to the player's hand whenever PlayerDeck is clicked.
func _on_PlayerDeck_card_drawn(card: Card) -> void:
	if (card != null):
		$Hand.add_card(card, $PlayerDeck.global_position)


# Determine if a card is being played when a card is released.
# If a card is being played, apply all its effects, otherwise do nothing.
func _on_Hand_card_released(card: Card) -> void:
	var in_bounds = get_global_mouse_position().y < get_viewport_rect().size.y * vert_play_limit
	if in_bounds:
		card.disable()
		activate_card(card)
	else:
		$Hand.update_hand()


# Visually moves cards back to the deck.
func _on_CardReturnTimer_timeout() -> void:
	# Get next card to move
	var card: Card = queue_return.pop_front()
	# Move card to the deck.
	$Hand.scale_card(card, $Hand.SCALE_START * 0.9)
	$Hand.move_card(card, $PlayerDeck.position)
	# Add a copy of the card to the bottom of the deck.
	var card_copy: Card = card.duplicate()
	card_copy.reset_timer()
	$PlayerDeck.add_card_under(card_copy)
	# Queue for deletion
	queue_delete.append(card)
