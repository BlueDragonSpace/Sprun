extends "res://inGame/npc/npc.gd"

@export var sprun_slots = 8
@export_range(0, 360) var sprun_container_angle = 135
@export var sprun_distance = 0 ## wow that's pretty cool
const SPRUN = preload("uid://b6wgjet502thq")
@export var sprun_active: int = 1

@export var defendStat = 6

@onready var sprun_container: Control = $VBoxContainer/Icon/SprunContainer

func add_ready() -> void:
	for slot in range(0, sprun_slots):
		var sprun = SPRUN.instantiate()
		
		sprun_container.add_child(sprun)
		sprun.pivot_offset.y += sprun_distance
		sprun.position.y -= sprun_distance
		@warning_ignore("integer_division")
		sprun.position -= Vector2(128 / 2, 128 / 2) # 128 comes from the Godot Sprite's original dimensions
		
		
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(45/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(-sprun_container_angle/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(slot * sprun_container_angle / (sprun_slots - 1))
	set_sprun()

func set_sprun():
	## I *would* set this as the set(new) method for active_sprun, but then it calls before ready and gives me an error
	
	# goes through and sets the individual spruns to be active or not
	for num in range(0, sprun_slots):
		if num < sprun_active - 1:
			sprun_container.get_child(num).active = true
		else:
			sprun_container.get_child(num).active = false
	
	if sprun_active > sprun_slots:
		print('wow you over charged on sprun congrats')
		
	sprun_active = clamp(sprun_active, 0, sprun_slots)

# player has it's intended actions set by the Root (because it's from input from the UI)

func attack():
	action_victim.take_damage(attackStat)
	Animate.play("attack")

func big_attack():
	# now, I could check here to make sure the player has the sprun needed to attack... but I'm gonna rely on the button to disable it'self instead 
	# plus it opens up the possibility to make a cheaper attack or decrease later on
	sprun_active -= 1
	
	action_victim.take_damage(int(attackStat * 1.5))
	Animate.play("attack")


func defend():
	self.current_defense += defendStat
	Animate.play("defend")

func focus():
	sprun_active += 1
	set_sprun()
