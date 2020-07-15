extends Node2D


const CARD_WIDTH = 362 / 2
const CARD_HEIGHT = 512 / 2
const CARD_SPACING = 200

const HAND_BUFFER = 100
const HAND_CURVE = 3

const MAX_ANGLE = PI / 4.0
const STEEPNESS = 0.002


# Load spell cards.
var cardExpelliarmus = load("res://Cards/CardExpelliarmus/CardExpelliarmus.tscn")
var cardFlipendo = load("res://Cards/CardFlipendo/CardFlipendo.tscn")
var cardRictusempra = load("res://Cards/CardRictusempra/CardRictusempra.tscn")

# Player's deck
var deck = [
	cardExpelliarmus.instance(),
	cardFlipendo.instance(),
	cardRictusempra.instance(),
]

var drawPile = deck.duplicate()

onready var hand = $Hand.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	shuffleDrawPile()
	updateDrawPile()
	
	print(get_viewport_rect())


# Shuffles the cards in the draw pile.
func shuffleDrawPile():
	pass


# Updates the draw pile icon.
func updateDrawPile():
	if (drawPile.empty()):
		$DrawPileButton.texture_normal = load("res://Arena/EmptyDeck.png")
	else:
		$DrawPileButton.texture_normal = load("res://Arena/FilledDeck.png")


# Adds the first card from the draw pile to the hand,
# and deletes it from the draw pile.
func drawCard():
	if (not drawPile.empty()):
		$Hand.add_child(drawPile.pop_front())
		updateDrawPile()
		updateHand()


# Update the positions and sizes of the cards in the hand.
func updateHand():
	hand = $Hand.get_children()
	var width = get_viewport_rect().size.x
	var height = get_viewport_rect().size.y
	
	# Figure out where each card should be placed
	# based on the number of cards and their width.
	var numCards = hand.size()
	var length = CARD_SPACING * (numCards - 1)
	var xBuffer = (width - length) / 2
	var yBuffer = height - HAND_BUFFER
	
	for i in range(hand.size()):
		var card = hand[i]
		var xDist = xBuffer + CARD_SPACING * i
		
		# The code below relates to the curve of the
		# cards in the player's hand.
		# Basically, it's
		# (x - w/2)^2 / (w * C) + (h + B)
		# Where x is the x-cord, w is the width, C is a curvature constant,
		# h is the height, and B is the buffer constant.
		var yDist = pow(xDist - (width / 2), 2) / (width * HAND_CURVE) + yBuffer
		
		card.position = Vector2(xDist, yDist)
		print("\t %s" % card.position)
		
		# Tilt cards based on position
		var angle = MAX_ANGLE / (1.0 + exp(-STEEPNESS * (xDist - width / 2.0))) - MAX_ANGLE / 2.0
		card.rotation = angle
		
	print("Hand updated")
		
		# (x-960)^2/7680+1024


# Runs when the draw pile button is pressed.
func _on_DrawPileButton_pressed():
	drawCard()
