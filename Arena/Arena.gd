extends Node2D


func _ready():
	print(get_viewport_rect().size) # TODO: Remove when convienient.
	
	$DuelerPlayer.opponent = $DuelerEnemy
	$DuelerEnemy.opponent = $DuelerPlayer
