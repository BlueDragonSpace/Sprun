extends "res://inGame/npc/npc.gd"

@export var sprun_slots = 8
@export_range(0, 360) var sprun_container_angle = 135
@export var sprun_distance = 0 ## wow that's pretty cool
const SPRUN = preload("uid://b6wgjet502thq")
@export var sprun_active: int = 0 # ONLY CHANGE WITH set_sprun(new_sprun_count)!!!!!!!!!!
@export var defendStat = 6

@export var new_action: Array[Resource]
var new_action_callable = [] #pass in the callables here

@onready var SprunContainer: Control = $VBoxContainer/Icon/SprunContainer

const ACTION_BUTTON = preload("uid://drtw4kuprkapi")
 
func add_ready() -> void:
	npc_type = CHARACTER_TYPE.PLAYER
	
	for slot in range(0, sprun_slots):
		var sprun = SPRUN.instantiate()
		
		SprunContainer.add_child(sprun)
		sprun.pivot_offset.y += sprun_distance
		sprun.position.y -= sprun_distance
		@warning_ignore("integer_division")
		#sprun.position -= Vector2(128 / 2, 128 / 2) # 128 comes from the Godot Sprite's original dimensions
		
		
		@warning_ignore("integer_division")
		#sprun.visual_rotation += deg_to_rad(45/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(-sprun_container_angle/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(slot * sprun_container_angle / (sprun_slots - 1))
	set_sprun(sprun_active)
	
	double_add_ready()

func double_add_ready() -> void:
	# at this point we may as well make this a running joke
	pass

func set_action_ui() -> void:
	# for every individual character, their individual actions need to be shown by the UI
	# Back Button will always remain the same, and the actions contained inside of 
	# - this script are available to every character
	# Once we figure out what every action needed for the UI is, we need to add them to UI,
	# then add the signals and connections for them, as if manually, but through code (duh)
	pass

func add_actions(custom_actions : Array) -> void:
	# every player has basics:
			# attack, defend, focus, pass
			# they also all have back button but that isn't controlled here
	
	
	for this_action in custom_actions:
		var new_button = ACTION_BUTTON.instantiate()
		new_button.info = this_action.button_info
		new_button.sprun_cost = this_action.sprun_necessary
		new_button.text = this_action.name
		
		@warning_ignore("standalone_expression")
		var lambda = func() : null
		match(this_action.action_type):
			0: ## ATTACK
				lambda = func(): 
					intended_action = Callable(self, this_action.func_name)
					Root.initiate_select_enemy()
					print('called the lambda')
		
		new_button.connect("pressed", lambda)
		
		# 0 is Back Button, so everything past that is fair game
		Root.Actions.get_child(this_action.action_type + 1).add_child(new_button)
		
		
		# set signal
		# connect signal
		# add button
		
		# hide unnessary tabs also


func set_sprun(new_sprun_count):
	## I *would* set this as the set(new) method for active_sprun, but then it calls before ready and gives me an error
	
	sprun_active = new_sprun_count
	
	# goes through and sets the individual spruns to be active or not
	for num in range(0, sprun_slots):
		if num < sprun_active:
			SprunContainer.get_child(num).active = true
		else:
			SprunContainer.get_child(num).active = false
	
	if sprun_active > sprun_slots:
		print('wow you over charged on sprun congrats')
		
	sprun_active = clamp(sprun_active, 0, sprun_slots)

# player has it's intended actions set by the Root (because it's from input from the UI)

func initiate_attack(action_name: String):
	
	self.intended_action = Callable(self, action_name)
	Root.initiate_select_enemy()

func attack():
	action_victim.take_damage(attackStat)
	Animate.play("attack")

func big_attack():
	# now, I could check here to make sure the player has the sprun needed to attack... but I'm gonna rely on the button to disable it'self instead 
	# plus it opens up the possibility to make a cheaper attack or decrease later on
	set_sprun(sprun_active - 1)
	
	action_victim.take_damage(int(attackStat * 2.5))
	Animate.play("attack")

func defend():
	self.current_defense += defendStat
	Animate.play("defend")

func focus():
	set_sprun(sprun_active + 1)
