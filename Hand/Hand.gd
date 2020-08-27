tool
extends Node2D


const SCALE_START = Vector2(0.5, 0.5)
const SCALE_DEFAULT = Vector2(0.66, 0.66)
const SCALE_FOCUS = Vector2(0.75, 0.75)

export var max_dist: float = 0.75
export var dist_curve: float = -0.05
export var pos_curve: float = 0.25

export(float, 0, 360, 0.01) var max_angle = 180
export var angle_curve: float = 0.5

var dist = max_dist
var selected_card: Card = null
var offset := Vector2(0, 0)


func _process(delta):
	if Engine.editor_hint:
		update()
	elif selected_card != null:
		selected_card.global_position = get_global_mouse_position() - offset


func _draw():
	if Engine.editor_hint:
		var points = PoolVector2Array()
		for x in range(-512, 512, 64):
			var y: float = x * x / get_viewport_rect().size.x * pos_curve
			points.append(Vector2(x, y))
			
			var angle = deg2rad(max_angle) / (1 + exp(-angle_curve / 1000 * x)) - deg2rad(max_angle) / 2
			var dir_start = Vector2(sin(angle), -cos(angle)) * 32 + Vector2(x, y)
			var dir_end = -Vector2(sin(angle), -cos(angle)) * 32 + Vector2(x, y)
			draw_line(dir_start, dir_end, Color.cornflower, 2.0, true)
			
		draw_polyline(points, Color.red, 2.0, true)


func add_card(card: Card, position: Vector2) -> void:
	$Cards.add_child(card)
	card.global_position = position
	card.scale = SCALE_START
	card.connect("focused", self, "update_hand")
	card.connect("unfocused", self, "update_hand")
	card.connect("pressed", self, "select_card")
	card.connect("released", self, "release_card")
	update_hand()


func update_hand(focus_card: Card = null) -> void:
	dist = max_dist * exp($Cards.get_child_count() * dist_curve)
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
	var y_pos: float = x_pos * x_pos / get_viewport_rect().size.x * pos_curve
	
	return Vector2(x_pos, y_pos)


func target_rot(card: Card) -> float:
	return deg2rad(max_angle) / (1 + exp(-angle_curve / 1000 * target_pos(card).x)) - deg2rad(max_angle) / 2
	

func select_card(card: Card) -> void:
	selected_card = card
	offset = get_global_mouse_position() - selected_card.global_position


func release_card() -> void:
	selected_card = null
	update_hand()
