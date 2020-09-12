tool
class_name Dueler
extends Node2D
# Holds a character sprite, deck, and card hand, and its related logic.
# Handles the deck and card hand positions of the player 
# and AI, and the logic of the turn-based combat.


signal card_played(card)
signal turn_ended
signal shake(amount)

# A float between 0-1 describing how far up the screen a card can be "played",
# i.e. a value of 0.5 means if the player lets go of the card in
# the top 50% of the window, the card will be considered played.
export(String) var dueler_name = "Harry"
export(int) var max_health := 10
export(int) var max_energy := 3
export(Texture) var sprite_texture := load("res://Character/character_blank.png")
export(bool) var is_player
export(float, 1) var vert_play_limit := 0.66

var screen_rect: Vector2

var FloatingText := preload("res://Arena/FloatingText.tscn")

var CardExpelliarmus := load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var CardFlipendo := load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var CardRictusempra := load("res://Cards/CardRictusempra/CardRictusempra.tscn")

var cards = [CardExpelliarmus, CardFlipendo, CardRictusempra]
var opponent: Dueler
var is_turn := false

var queue_playing := []
var queue_delete := []

onready var health: int = max_health
onready var energy: int = max_energy


func _ready() -> void:
	$Sprite.texture = sprite_texture
	
	if not Engine.editor_hint:
		randomize()
		screen_rect = get_viewport_rect().size
		update_health()
		update_energy()
		# Add 10 random cards to the deck.
		for _i in range(10):
			cards.shuffle()
			var rand_card = cards.front()
			$Deck.add_card_ontop(rand_card.instance())


func _draw() -> void:
	if Engine.editor_hint and is_player:
		# Draws a rectangle to visually indicate where cards can be played.
		var size := screen_rect * Vector2(1, vert_play_limit)
		draw_rect(Rect2(Vector2(0, 0), size), Color.dimgray, true, 1.0)


func _process(_delta) -> void:
	# Update _draw()
	if Engine.editor_hint:
		$Sprite.texture = sprite_texture
		update()


# Activate the given card's abilities.
func activate_card(card: Card) -> void:
	for ability in card.abilities:
		match ability.type:
			Global.Ability.PLAYABLE:
				play_card(card)
			Global.Ability.UNPLAYABLE:
				pass
			Global.Ability.DISCARD:
				discard_card(card)
			Global.Ability.DAMAGE:
				attack(ability.value)
			_:
				var type: String = Global.Ability.keys()[ability.type]
				print("Invalid Ability ", type)
	$Hand.update_hand()


# Draws cards from the deck to the hand.
func draw_to_hand(num: int = 1) -> void:
	for _i in range(num):
		var card: Card = $Deck.draw_card()
		if (card != null):
			$Hand.add_card(card, $Deck.global_position)
			if is_player:
				card.show_front()
			else:
				card.disable_timer()
			yield(get_tree().create_timer(0.15), "timeout")


# Tweens the card to the middle of the
# screen to indicate that it has been played.
func play_card(card: Card) -> void:
	# Remove prior cards.
	if (!queue_playing.empty()):
		for remaining_card in queue_playing:
			emit_signal("card_played", remaining_card)
	
	queue_playing.append(card)
	card.disable()
	card.get_node("Cost").visible = false
	energy -= card.cost
	update_energy()
	
	# Disconnect card from Hand node and add it to the Cards node.
	card.position = card.global_position
	card.get_parent().remove_child(card)
	$Cards.add_child(card)
	
	# Move card to middle of screen.
	$Tween.interpolate_property(card, "scale", card.scale,
			Global.SCALE_FOCUS, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "rotation", card.rotation,
			0, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "position", card.position,
			screen_rect * Vector2(0.5, 0.5), 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "back_alpha", card.back_alpha,
			0, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("card_played", card)


# Sends the card to the discard pile after a card has been played.
func discard_card(card: Card) -> void:
	var played_card: Card = yield(self, "card_played")
	while (card != played_card):
		played_card = yield(self, "card_played")
	queue_playing.erase(card)
	force_discard(played_card)


# Sends the card to the discard pile regardless of state.
func force_discard(card: Card) -> void:
	card.show_back()
	# Set cards behind the deck.
	card.z_index = $Deck.z_index - 1
	# Move card to the deck.
	$Tween.interpolate_property(card, "scale", card.scale,
			Global.SCALE_START * 0.25, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(card, "rotation", card.rotation,
			-2*PI, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(card, "position:x", card.position.x,
			$Deck.position.x, 1, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(card, "position:y", card.position.y,
			$Deck.position.y, 1, Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.interpolate_property(card, "back_alpha", 0.0,
			1.0, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	
	# Add a copy of the card to the bottom of the deck.
	var card_copy: Card = card.duplicate()
	card_copy.reset_timer()
	$Deck.add_card_under(card_copy)
	
	queue_delete.append(card)


# Deals damage to the opponent.
func attack(amount: int) -> void:
	# Attack animation.
	animate_displace(50)
	# Delay the hurt animation by a fraction of a second.
	yield(get_tree().create_timer(0.2), "timeout")
	opponent.animate_displace(-30)
	
	opponent.health -= amount
	opponent.update_health()
	
	opponent.emit_floating_text("-" + String(amount), Color.firebrick)
	emit_signal("shake", amount * 2)


# Updates the health bar.
func update_health() -> void:
	var health_bar = $Sprite/Health/HealthBar
	health_bar.max_value = max_health
	health_bar.value = health
	$Sprite/Health/HealthLabel.text = "%d/%d" % [health, max_health]
	
	yield(get_tree().create_timer(0.5), "timeout")
	var tween_bar = $Sprite/Health/TweenBar
	tween_bar.step = 0.01
	tween_bar.max_value = max_health
	$Tween.interpolate_property(tween_bar, "value", tween_bar.value,
			health_bar.value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


# Updates the energy bar.
func update_energy() -> void:
	var energy_bar = $Sprite/Energy/EnergyBar
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	$Sprite/Energy/EnergyLabel.text = "%d/%d" % [energy, max_energy]
	
	yield(get_tree().create_timer(0.5), "timeout")
	var tween_bar = $Sprite/Energy/TweenBar
	tween_bar.step = 0.01
	tween_bar.max_value = max_energy
	$Tween.interpolate_property(tween_bar, "value", tween_bar.value,
			energy_bar.value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

# Returns a boolen if the card can be played.
# Checks if the dueler has enough energy and if it's currently its turn.
# Does not check mouse postiion, which is done by the `in_bounds()` function.
func can_play(card: Card) -> bool:
	if (energy >= card.cost):
		return is_turn
	else:
		return false


# Checks if the mouse is within the play bounds.
func in_bounds() -> bool:
	return get_global_mouse_position().y < screen_rect.y * vert_play_limit


# Displaces the sprite node by `displace`,
# then tweens it back to the original position.
# Used for attacking and hurt animations.
func animate_displace(displace: int) -> void:
	var sprite_pos = $Sprite.position
	if !is_player:
		displace *= -1
	$Sprite.position.x += displace
	$Tween.interpolate_property($Sprite, "position", $Sprite.position,
			sprite_pos, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


# Creates floating text that pops out of the dueler.
# Used when dueler is damaged to indicate damage taken.
func emit_floating_text(text: String, color: Color) -> void:
	var floating_text = FloatingText.instance()
	floating_text.text = text
	floating_text.position = $Sprite.position + Vector2(0, -$Sprite.texture.get_height() * $Sprite.scale.y * 0.5)
	floating_text.velocity = Vector2(rand_range(-100, 100), -100)
	floating_text.modulate = color
	add_child(floating_text)


# Play out turn according to the Logic script.
# Having a separate script allows for adaptability
# for player, AI and other input logic.
func play_turn() -> void:
	is_turn = true
	energy = max_energy
	update_energy()
	draw_to_hand()
	yield($Logic.play_turn(), "completed")


# Signals that the dueler's turn has been ended.
func emit_ended_turn() -> void:
	is_turn = false
	emit_signal("turn_ended")


# Determines if a card is being played when a card is released.
# If a card is being played, apply all its effects, otherwise do nothing.
func _on_Hand_card_released(card: Card) -> void:
	if (in_bounds() and can_play(card)):
		activate_card(card)
	$Hand.update_hand()


# Called when all tweens are finished, and deletes any cards in queue.
func _on_Tween_all_completed() -> void:
	# Delete any card queued for deletion.
	for item in queue_delete:
		for card in $Cards.get_children():
			if (item == card):
				card.queue_free()


func _on_Hand_card_moved(card: Card, pos: Vector2) -> void:
	card.global_position = pos
	$Hand.scale_card(card, Global.SCALE_DEFAULT)
	
	if (in_bounds() and can_play(card)):
		card.glow_playable()
	else:
		card.glow_selection()
