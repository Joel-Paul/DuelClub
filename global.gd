extends Node


enum Stance {
	NONE,
	AGGRESSIVE,
	DEFENSIVE,
	SNEAKY,
}

enum Ability {
	NONE,
	PLAYABLE,
	UNPLAYABLE,
	DISCARD,
	DAMAGE,
}

const SCALE_START = Vector2(0.5, 0.5)
const SCALE_DEFAULT = Vector2(0.66, 0.66)
const SCALE_FOCUS = Vector2(0.75, 0.75)
