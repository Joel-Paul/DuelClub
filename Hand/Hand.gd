extends Node2D


const MAX_DIST = 0.75
const DIST_CURVE = -0.05
const POS_CURVE = 0.25

const MAX_ANGLE = PI
const ANGLE_STEEPNES = 0.0005

const SCALE_START = Vector2(0.5, 0.5)
const SCALE_DEFAULT = Vector2(0.66, 0.66)
const SCALE_FOCUS = Vector2(0.75, 0.75)

var dist = MAX_DIST


func add_card(card: Card, position: Vector2) -> void:
	$Cards.add_child(card)
	card.global_position = position
	card.scale = SCALE_START
	card.connect("focused", self, "update_hand")
	card.connect("unfocused", self, "update_hand")
	update_hand()


func update_hand(focus_card:Card = null) -> void:
	dist = MAX_DIST * exp($Cards.get_child_count() * DIST_CURVE)
	for card in $Cards.get_children():
		var card_scale = SCALE_DEFAULT
		var card_rot = target_rot(card)
		var card_pos = target_pos(card)
		
		if (focus_card == card):
			card_scale = SCALE_FOCUS
			card.scale = card_scale
			card_rot = 0
			card.rotation = card_rot
			card_pos.y = -card.height / 3
			card.position.y = card_pos.y
		elif (focus_card != null):
			var disp: float = (focus_card.width / 2) / (card.get_index() - focus_card.get_index())
			card_pos += Vector2(disp, 0)
		
		card.tween_to_scale(card_scale)
		card.tween_to_rot(card_rot)
		card.tween_to_pos(card_pos)


# Returns the coordinate position we want the card to go to.
func target_pos(card: Card) -> Vector2:
	var size: float = $Cards.get_child_count()
	var index: float = card.get_index()
	
	var x_pos: float = (index - (size - 1.0) / 2.0) * card.width / card.scale.x * SCALE_DEFAULT.x * dist
	var y_pos: float = x_pos * x_pos / get_viewport_rect().size.x * POS_CURVE
	
	return Vector2(x_pos, y_pos)


func target_rot(card: Card) -> float:
	return MAX_ANGLE / (1 + exp(-ANGLE_STEEPNES * target_pos(card).x)) - MAX_ANGLE / 2
