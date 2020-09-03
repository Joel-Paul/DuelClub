tool
extends Node2D
# Stores a list of cards as children of a node and displays them curve.
# The curve and angles of the cards in the hand can be modified.


signal card_released(card)
signal card_moved(card, pos)

# Tweakable variables that impact the cards' position and rotation.
export var max_dist: float = 0.75
export var dist_curve: float = -0.05
export var pos_curve: float = 0.25
export(float, 0, 360, 0.01) var max_angle = 180
export var angle_curve: float = 0.5

var dist = max_dist
var selected_card: Card = null
var offset := Vector2(0, 0)


func _draw():
	# Draws a preview of the hand's position in the editor.
	if Engine.editor_hint:
		var points = PoolVector2Array()
		for x in range(-512, 513, 64):
			# Store the points along the curve.
			var y: float = x * x / get_viewport_rect().size.x * pos_curve
			points.append(Vector2(x, y))
			
			# Draw a line representing the angle of the cards at each point.
			var angle = deg2rad(max_angle) / (1 + exp(-angle_curve / 1000 * x)) - deg2rad(max_angle) / 2
			var dir_start = Vector2(sin(angle), -cos(angle)) * 32 + Vector2(x, y)
			var dir_end = -Vector2(sin(angle), -cos(angle)) * 32 + Vector2(x, y)
			draw_line(dir_start, dir_end, Color.cornflower, 2.0, true)
		# Use the stored points to draw a line.
		draw_polyline(points, Color.red, 2.0, true)


func _process(_delta):
	if Engine.editor_hint:
		# Updates _draw().
		update()
	elif selected_card != null:
		var target = get_global_mouse_position() - offset
		emit_signal("card_moved", selected_card, target)


# Add a card to the hand and spawn it at the given position.
func add_card(card: Card, position: Vector2) -> void:
	$Cards.add_child(card)
	card.global_position = position
	card.scale = Global.SCALE_START
	card.modulate.a = 0
	update_hand()
	
	card.connect("focused", self, "update_hand")
	card.connect("unfocused", self, "update_hand")
	card.connect("pressed", self, "select_card")
	card.connect("released", self, "release_card")


# Move all cards to their appropriate positions.
# If a `focus_card` is given, make extra space for it.
func update_hand(focus_card: Card = null) -> void:
	# `dist` represents the distance of each card from each other.
	dist = max_dist * exp($Cards.get_child_count() * dist_curve)
	
	for card in $Cards.get_children():
		card.z_index = card.get_index() + 9
		
		var card_scale = Global.SCALE_DEFAULT
		var card_rot = target_rot(card)
		var card_pos = target_pos(card)
		
		if (focus_card == card):
			# Focus on this card (make it larger, etc.).
			card_scale = Global.SCALE_FOCUS
			card.scale = card_scale
			card_rot = 0
			card.rotation = card_rot
			card_pos.y = -card.height / 3
			card.position.y = card_pos.y
			card.z_index = 32
		elif (focus_card != null):
			# `focus_card` exists, but it's not this card, so displace this card
			# by a certain amount depening on how far it is from `focus_card`.
			var disp: float = (focus_card.width / 2) / (card.get_index() - focus_card.get_index())
			card_pos += Vector2(disp, 0)
		
		$Tween.interpolate_property(card, "modulate", card.modulate,
			Color(1, 1, 1, 1), 1, Tween.TRANS_QUART, Tween.EASE_OUT)
		scale_card(card, card_scale)
		rotate_card(card, card_rot)
		move_card(card, card_pos)


# Tweens card to a scale.
func scale_card(card: Card, amount: Vector2):
	$Tween.interpolate_property(card, "scale", card.scale,
			amount, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()


# Tweens card to a rotaiton.
func rotate_card(card: Card, rot: float):
	$Tween.interpolate_property(card, "rotation", card.rotation,
			rot, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


# Tweens card to a position.
func move_card(card: Card, pos: Vector2):
	$Tween.interpolate_property(card, "position", card.position,
			pos, 1, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()


# Returns the coordinate position we want the card in the hand to go to.
func target_pos(card: Card) -> Vector2:
	var size: float = $Cards.get_child_count()
	var index: float = card.get_index()
	
	var x_pos: float = (index - (size - 1.0) / 2.0) * card.width / card.scale.x * Global.SCALE_DEFAULT.x * dist
	var y_pos: float = x_pos * x_pos / get_viewport_rect().size.x * pos_curve
	
	return Vector2(x_pos, y_pos)


# Returns the rotation in radians we want the card in the hand to be at.
func target_rot(card: Card) -> float:
	return deg2rad(max_angle) / (1 + exp(-angle_curve / 1000 * target_pos(card).x)) - deg2rad(max_angle) / 2
	

# Stores a reference to the selected card.
func select_card(card: Card) -> void:
	selected_card = card
	offset = get_global_mouse_position() - selected_card.global_position


# Emits a signal when a card is released.
func release_card(card: Card) -> void:
	selected_card = null
	emit_signal("card_released", card)
