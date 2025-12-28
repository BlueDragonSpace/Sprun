extends "res://inGame/player/player.gd"


func mega_lazer() -> void:
	
	action_victim.take_damage(attackStat * 7)
	Animate.play("attack")
	
	print('That was a mega lazer, imagine the special effects')

func double_add_ready() -> void:
	pass
	
	# welp, 0 means on, 1 means off
	# my entire binary knowledge is garbage
	
	#var actia = new_action[0]
	#print(actia.name)
	#print(actia.player_type)
	#print(actia.player_type & 0)
	#print(actia.player_type & 1)
	#print(actia.player_type % 2)
	#print(actia.player_type % 3)
	#print(actia.player_type % 4)
