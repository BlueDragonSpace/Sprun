extends "res://inGame/player/player.gd"

#func call_mouse() -> void:
	## cannot attack or dfd
	#pass
#
#func call_hamster() -> void:
	## chunky
	#pass

const RAT = preload("uid://c02utralqt5h")
func call_rat() -> void:
	Root.Charas.add_child(RAT.instantiate())
	set_sprun(sprun_active - 1)
	# poison damage?
