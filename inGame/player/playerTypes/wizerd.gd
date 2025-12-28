extends "res://inGame/player/player.gd"



@warning_ignore("unused_signal")
signal mega_lazer_signal

func mega_lazer() -> void:
	action_victim.take_damage(attackStat * 7)
	Animate.play("attack")
	print('That was a mega lazer, imagine the special effects')

func _ready() -> void:
	add_actions([["Mega Lazer", mega_lazer, mega_lazer_signal, 1, 'mega powered mega beam mega mega']])
