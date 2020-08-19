extends Node2D


const CARD_DIST = 0.75


func add_card(card: Card) -> void:
	$Cards.add_child(card)
	update_hand()


func update_hand() -> void:
	var tween := $Tween
	for card in $Cards.get_children():
		tween.interpolate_property(card, "position", card.position,
				target_pos(card), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	print("")


# Returns the coordinate position we want the card to go to.
func target_pos(card: Card) -> Vector2:
	var size: float = $Cards.get_child_count()
	var index: float = card.get_index()
	
	var x_pos: float = (index - (size - 1) / 2) * card.width * card.scale.x * CARD_DIST
	var y_pos: float = x_pos * x_pos / get_viewport_rect().size.x
	
	print(x_pos, ", ", y_pos)
	
	return Vector2(x_pos, y_pos)
