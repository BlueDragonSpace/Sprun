extends "res://inGame/player/player.gd"


func mega_lazer() -> void:
	
	# add basic code for an attack in npc?
	
	action_victim.take_damage(attackStat * 7)
	Animate.play("attack")
	
	print('That was a mega lazer, imagine the special effects')



func double_add_ready() -> void:
	print('double_add_read')
	new_action_callable.push_back(mega_lazer)
	#add_actions(new_action)
	call_deferred("add_actions", new_action)
