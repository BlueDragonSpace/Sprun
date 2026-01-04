extends "res://inGame/player/player.gd"

@onready var WizerdAnimate: AnimationPlayer = $WizerdAnimate

func mega_lazer() -> void:
	
	action_victim.take_damage(attack_stat * 7)
	WizerdAnimate.play("mega_lazer")
	
	set_sprun(sprun_active - 2) # ? blunder, this should be set inside of the action...
	
	$MegaLazer.play()

func die() -> void:
	# yup, redefined for funzies
	
	# you can only die once
	if is_dead == false:
		is_dead = true
		Root.remove_dead_actions(self)
		Animate.call_deferred("play", "die")
	
	$wawaawawawa.play()
