extends Node2D


const MAX_DIST = 0.75
const DIST_CURVE = -0.05
const POS_CURVE = 0.25

const MAX_ANGLE = PI
const ANGLE_STEEPNES = 0.0005

const SCALE_START = Vector2(0.5, 0.5)

var dist = MAX_DIST


func add_card(card: Card, position: Vector2) -> void:
	$Cards.add_child(card)
	card.global_position = position
	card.scale = SCALE_START
	update_hand()


func update_hand() -> void:
	dist = MAX_DIST * exp($Cards.get_child_count() * DIST_CURVE)
	var tween := $Tween
	for card in $Cards.get_children():
		# Tween the card's position
		tween.interpolate_property(card, "position", card.position,
				target_pos(card), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		# Tween the card's rotation
		tween.interpolate_property(card, "rotation", card.rotation,
				target_rot(card), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		# Tween the card's SCALE
		tween.interpolate_property(card, "scale", card.scale,
				card.SCALE_DEFAULT, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


# Returns the coordinate position we want the card to go to.
func target_pos(card: Card) -> Vector2:
	var size: float = $Cards.get_child_count()
	var index: float = card.get_index()
	
	var x_pos: float = (index - (size - 1.0) / 2.0) * card.width * card.SCALE_DEFAULT.x * dist
	var y_pos: float = x_pos * x_pos / get_viewport_rect().size.x * POS_CURVE
	
	return Vector2(x_pos, y_pos)


func target_rot(card: Card) -> float:
	return MAX_ANGLE / (1 + exp(-ANGLE_STEEPNES * target_pos(card).x)) - MAX_ANGLE / 2
