extends "res://inGame/player/player.gd"

#func call_mouse() -> void:
	## cannot attack or dfd
	#pass
#
#func call_hamster() -> void:
	## chunky
	#pass

var rat_count = 1

const RAT = preload("uid://c02utralqt5h")

func call_rat() -> void:
	
	var rat = RAT.instantiate()
	rat.name = "Rat " + str(rat_count)
	Root.Charas.add_child(rat)
	set_sprun(sprun_active - 2)
	# poison damage?
	
	rat_count += 1
	$RatSpawning.play()
