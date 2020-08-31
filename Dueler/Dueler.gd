tool
extends Node2D
# Holds a character sprite, deck, and card hand, and its related logic.
# Handles the deck and card hand positions of the player 
# and AI, and the logic of the turn-based combat.


# A float between 0-1 describing how far up the screen a card can be "played",
# i.e. a value of 0.5 means if the player lets go of the card in
# the top 50% of the window, the card will be considered played.
export(int) var max_health = 10
export(float, 1) var vert_play_limit = 0.5

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var CardFlipendo := load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var CardRictusempra := load("res://Cards/CardRictusempra/CardRictusempra.tscn")

var health = max_health
var cards = [CardExpelliarmus, CardFlipendo, CardRictusempra]
var queue_return = []
var queue_delete = []


func _ready() -> void:
	if not Engine.editor_hint:
		print(get_viewport_rect().size) # TODO: Remove when convienient.
		update_health()
		# Add 10 random cards to the deck.
		for _i in range(10):
			cards.shuffle()
			var rand_card = cards.front()
			$Deck.add_card_ontop(rand_card.instance())


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
			Global.Ability.DAMAGE:
				damage(ability.value)
			_:
				print("Invalid Ability!")


# Tweens the card to the middle of the screen, then after
# the timer has timeed out, tweens the card back to the
# deck, adds a copy of it to the deck, then frees it.
func return_to_deck(card: Card) -> void:
	# Prevent the card from being selected again.
	card.disable()
	
	card.z_index -= $Deck.z_index
	
	# Disconnect card from Hand node and add it to the Arena node.
	card.position = card.global_position
	card.get_parent().remove_child(card)
	$Cards.add_child(card)
	
	# If a previous card is still waiting, skip its wait time.
	if ($ReturnTimer.time_left != 0):
		_on_ReturnTimer_timeout()
	
	# Move card to middle of screen so the player
	# has visual indication that it has been played.
	$Tween.interpolate_property(card, "scale", card.scale,
			Global.SCALE_FOCUS * 1.1, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "rotation", card.rotation,
			0, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "position", card.position,
			get_viewport_rect().size / 2, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	
	# Queue for it to move to the deck.
	queue_return.append(card)
	$ReturnTimer.start()


# Deals damage to the opponent.
func damage(amount: int) -> void:
	print("Dealt ", amount, " damage!")


# Update the health bar.
func update_health() -> void:
	$Sprite/HealthBar.max_value = max_health
	$Sprite/HealthBar.value = health
	$Sprite/HealthBar/HealthLabel.text = "%d/%d" % [health, max_health]


# Add a card to the player's hand whenever PlayerDeck is clicked.
func _on_PlayerDeck_card_drawn(card: Card) -> void:
	if (card != null):
		$Hand.add_card(card, $Deck.global_position)


# Determine if a card is being played when a card is released.
# If a card is being played, apply all its effects, otherwise do nothing.
func _on_Hand_card_released(card: Card) -> void:
	var in_bounds = get_global_mouse_position().y < get_viewport_rect().size.y * vert_play_limit
	if in_bounds:
		activate_card(card)
	$Hand.update_hand()


# Visually moves card back to the deck.
func _on_ReturnTimer_timeout() -> void:
	# Get next card to move
	var card: Card = queue_return.pop_front()
	
	# Move card to the deck.
	$Tween.interpolate_property(card, "scale", card.scale,
			Global.SCALE_START * 0.5, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "rotation", card.rotation,
			0, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "position", card.position,
			$Deck.position, 1, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	$Tween.start()
	
	# Add a copy of the card to the bottom of the deck.
	var card_copy: Card = card.duplicate()
	card_copy.reset_timer()
	$Deck.add_card_under(card_copy)
	
	# Queue for deletion
	queue_delete.append(card)


# Called when all tweens are finished, and deletes any cards in queue.
func _on_Tween_all_completed() -> void:
	# Delete any card queued for deletion.
	for item in queue_delete:
		for card in $Cards.get_children():
			if (item == card):
				card.queue_free()
