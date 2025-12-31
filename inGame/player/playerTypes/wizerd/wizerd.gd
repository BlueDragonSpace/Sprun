extends "res://inGame/player/player.gd"


func mega_lazer() -> void:
	
	action_victim.take_damage(attackStat * 7)
	Animate.play("attack")
	
	print('That was a mega lazer, imagine the special effects')
