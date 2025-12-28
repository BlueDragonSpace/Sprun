extends Control

@onready var NoiseBackground: TextureRect = $NoiseBackground
@onready var Actions: TabContainer = $RootGame/LowerBar/VBoxContainer/Actions
@onready var BAK: Button = $RootGame/LowerBar/VBoxContainer/Actions/BackButton/BAK
@onready var LittlePlayerIcon: TextureRect = $RootGame/LowerBar/VBoxContainer/InfoBar/LittlePlayerIcon
@onready var ActionInfo: Label = $RootGame/LowerBar/VBoxContainer/InfoBar/ActionInfo


@onready var Animate: AnimationPlayer = $Animate

var current_player = null:
	set(new):
		LittlePlayerIcon.texture = new.icon
		current_player = new
var current_enemy = null

@onready var Charas: VBoxContainer = $RootGame/BattleScreen/Charas
@onready var Enemies: VBoxContainer = $RootGame/BattleScreen/Enemies
@onready var TurnOrder: VBoxContainer = $RootGame/BattleScreen/TurnOrder/TurnOrder
@onready var TurnOrderPointMaster: TextureRect = $RootGame/BattleScreen/TurnOrder/TurnOrderPointMaster
var temp_turn_order_point = null # turns into node which is turned into a tween for the master

const TURN_ORDER_POINT = preload("uid://kbdvggtyupd2") # current turn marker
const TURN_ORDER_MARKER = preload("uid://dim074qeqwx6x") # character/enemy order
const ENEMY_SELECTION = preload("uid://c6hsrr8o4xvi3")


## player section
var player_actions = []
## mid section
var mid_animation_action = func() : pass
var turn_order_data = [] # speed_stat, icon, node_path, action
var current_turn = 0
## end section

## In-Battle
enum TURN_TYPE {PLAYER, SELECT_ENEMY, MIDDLE, END, TRANSITION}
@export var turn = TURN_TYPE.PLAYER:
	set(new):
		match(new):
			TURN_TYPE.PLAYER:
				disable_all_actions(false)
				BAK.disabled = true
				check_cost_all_actions(current_player.sprun_active)
				check_actions_visible(current_player.player_type)
			TURN_TYPE.SELECT_ENEMY:
				disable_all_actions(true)
				BAK.disabled = false
				back_action = func(): 
					turn = TURN_TYPE.PLAYER
					current_enemy.get_child(-1).queue_free()
					BAK.disabled = true
					# may be worth turning the back_action to be the empty function
			TURN_TYPE.MIDDLE:
				middle_round_loop() # could just call this method in Animate...
			TURN_TYPE.END:
				BAK.disabled = true
				back_action = func(): Callable(Global, "empty_function")
				
			TURN_TYPE.TRANSITION:
				# this type is more like an empty function than anything else
				# it means that the Animate is going to another type, and right now
				# -it doesn't need to do anything
				pass
		turn = new

var back_action = Callable(Global, "empty_function")

var in_transition = false
var current_round = 0:
	set(new):
		$RootGame/TopBar/HBoxContainer/RoundNum.text = str(new)
		current_round = new

# the player types, for use within the root, as an array rather than one string
var root_player_type_array = Action.PLAYER_TYPE.split(', ')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_info("A last stand.")
	current_player = Charas.get_child(0)
	current_enemy = Enemies.get_child(0)
	check_cost_all_actions(current_player.sprun_active)
	check_actions_visible(current_player.player_type)
	
	BAK.disabled = true
	
	NoiseBackground.texture.noise.seed = randi()
	call_deferred("set_turn_order")
	set_enemies_intents()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	NoiseBackground.texture.noise.offset += Vector3(delta * 0.1, delta * 5, delta * 5)
	
	match(turn):
		pass
		#TURN_TYPE.ENEMY:
			#match(current_enemy.intent):
				#current_enemy.INTENTS.ATTACK:
					#mid_animation_action = func(): current_enemy.attack(current_player)
					#Animate.play("enemyAttack")
					##this thing is getting called way too many times...

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("TabAction"):
		if turn == TURN_TYPE.SELECT_ENEMY:
			# change the enemy selected (remove current selection from previous enemy, add it to new enemy); if it's the last enemy, choose the first
			current_enemy.get_child(-1).queue_free()
			
			var child_index = current_enemy.get_index()
			if child_index == Enemies.get_child_count() - 1:
				current_enemy = Enemies.get_child(0)
			else:
				current_enemy = Enemies.get_child(child_index + 1)
				
			var selector = ENEMY_SELECTION.instantiate()
			selector.connect("pressed", select_enemy)
			selector.text = ''
			selector.info = current_enemy.name
			selector.call_deferred("grab_focus")
			current_enemy.add_child(selector)

# custom functions

func set_enemies_intents() -> void:
	for enemy in Enemies.get_children():
		if enemy.is_dead == false:
			enemy.intent = randi_range(0,0) #currently only sets to attack
			var tween = create_tween()
			# makes the Intent visible again
			# it's worth noting that "Intent" and "intent" are two completely separate things
				#I capitalize NodePaths, and make variables lowercase...
			tween.tween_property(enemy.Intent, "modulate", Color(1.0,1.0,1.0,1.0),1.0)
			
			enemy.set_intended_action(current_player)

func set_turn_order() -> void:
	## sorts the Turn Order
	
	# remove all children of turn ordering
	for child in TurnOrder.get_children():
		TurnOrder.remove_child(child)
		turn_order_data = []
	
	
	for enemy in Enemies.get_children():
		if enemy.is_dead == false:
			turn_order_data.push_back([enemy.speedStat, enemy.Icon.texture, enemy, Callable(enemy, "do_intended_action")])
	# wonder if there is a such thing as a shared for loop..?
	for character in Charas.get_children():
		if character.is_dead == false:
			turn_order_data.push_back([character.speedStat, character.Icon.texture,character, Callable(character, "do_intended_action")])
	
	#as it turns out, Godot's sort method will sort by the first element of each array in a nested array
	# which makes life a whole lot easier than doing custom_sort()
	turn_order_data.sort()
	
	for body in turn_order_data:
		var marker = TURN_ORDER_MARKER.instantiate()
		marker.texture = body[1]
		TurnOrder.add_child(marker)
func tween_turn_order_point() -> void:
	#var tween = create_tween()
	#
	#
	#if current_turn == 0:
		## tweening doesn't matter here since the thing isn't visible yet
		#TurnOrderPointMaster.global_position.y = temp_turn_order_point.global_position.y
		#print('tweened to first position')
	#elif current_turn < turn_order_data.size():
		#tween.tween_property(TurnOrderPointMaster, "global_position:y", temp_turn_order_point.global_position.y, 0.19)
	#else:
		#tween.tween_property(TurnOrderPointMaster, "position:x", 167.0, 0.19) #tweens it out of the screen space
		#
	pass
func add_turn_order_point(point) -> void:
	var now_mark = TurnOrder.get_child(point)
	var new_turn_order_point = TURN_ORDER_POINT.instantiate()
	now_mark.add_child(new_turn_order_point)
	temp_turn_order_point = new_turn_order_point

func select_enemy() -> void:
	
	current_player.action_victim = current_enemy
	current_enemy.get_child(-1).queue_free()
	
	player_pass_turn()

func disable_all_actions(boolean: bool) -> void:
	for container in Actions.get_children():
		for action in container.get_children():
			action.disabled = boolean

func check_cost_all_actions(sprun: int) -> void:
	
	for container in Actions.get_children():
		for action in container.get_children():
			action.check_cost(sprun)

func check_actions_visible(player_type_bitwise: int) -> void:
	
	print(player_type_bitwise)
	
	# now, for every action, check if it is available to the character
	for tab in Actions.get_children():
		for action in tab.get_children():
			
			action.visible = false
			
			#print(action.name)
			#print(action.usable_on_player)
			#print(action.usable_on_player & 1)
			#print(action.usable_on_player & 2 and true)
			#print("---------------------")
			
			if action.usable_on_player & 1: # if 'All' is set, it's gonna be visible
				action.visible = true
				continue
			
			for bit in root_player_type_array.size(): # loops through every player type
				
				if action.usable_on_player & bit and player_type_bitwise & bit:
					# if the action and the player have at least one of the same bit type, the action is visible
					action.visible = true
					continue

func remove_dead_actions(dead: Node) -> void:
	# gets called by npc whenever it dies
	# for reference of turn_order_data: speed_stat, icon, node_path, action
	
	var num = current_turn
	
	# evaluated inside of a while loop so it dynamically changes the length of the loop while inside of it
	while num < turn_order_data.size():
		
		if turn_order_data[num][2] == dead:
			turn_order_data.remove_at(num)
			continue # if we remove the action at this point in the array, we need to re-read what this current action is, since all items forward are pushed back one, menaing the current action is new in this current index
			
		#print(turn_order_data[num][2].name + " is targeting " + turn_order_data[num][2].action_victim.name)
		if turn_order_data[num][2].action_victim == dead:
			if turn_order_data[num][2].action_victim is Node:
				turn_order_data.remove_at(num)
				continue
			elif turn_order_data[num][2].action_victim is Array:
				print('action_victim is array but I havent done that yet')
			else:
				print('what the hell')
				print('action victim is dead, but container is not a Node or Array')
				
		
		num += 1 # progress the loop
		
	
	match(dead.npc_type):
		dead.CHARACTER_TYPE.ENEMY:
			# solves the error that the current_enemy is freed on next read tho
			
			var total_wave_kill = true
			
			for loop in Enemies.get_child_count():
				if Enemies.get_child(loop).is_dead == false:
					total_wave_kill = false
					current_enemy = Enemies.get_child(loop)
					break
			
			if total_wave_kill:
				print("successfully made them begone of this world")
				get_tree().quit()
			
		dead.CHARACTER_TYPE.PLAYER:
			
			var total_party_kill = true
			
			for loop in Charas.get_child_count():
				if Charas.get_child(loop).is_dead == false:
					total_party_kill = false
					current_player = Charas.get_child(loop)
					break
			
			if total_party_kill:
				print("The entire party lost the will to continue.")
				get_tree().quit()
			

## turn focussed functions
func middle_animation_constant() -> void:
	# constant, in the sense that this function is constant, while the mid animation action is not
	mid_animation_action.call()
	mid_animation_action = func(): pass #resets the action to be nothing afterward
	#intended for use with lambda functions, in the middle of an animation

func middle_round_loop() -> void:
	
	
	
	if current_turn < turn_order_data.size():
		
		# different from prev_mark, cuz we changed the turn
		if current_turn < turn_order_data.size() and current_turn != 0:
			add_turn_order_point(current_turn)
		
		mid_animation_action = turn_order_data[current_turn][3]
		current_turn += 1
		
		if current_turn < turn_order_data.size() + 1:
			var prev_mark = TurnOrder.get_child(current_turn - 2)
			
			if current_turn != 0:
				if prev_mark.get_child_count() > 0:
					prev_mark.remove_child(prev_mark.get_child(-1))
		
		
		Animate.play("middle_round")
	else:
		final_pass_turn()

func final_pass_turn() -> void:
	button_info("wow it's ur turn nerd")
	
	# removes the turn order point from the last child of the last npc in turn order
	var last_npc = TurnOrder.get_child(-1)
	if last_npc.get_child_count() > 0:
		last_npc.remove_child(last_npc.get_child(-1))
	
	for num in range(0, Charas.get_child_count()):
		if Charas.get_child(num).is_dead == false:
			current_player = Charas.get_child(num) # sets the current_player to be not dead
		break
	
	set_enemies_intents()
	set_turn_order()
	Animate.play("to_player")
	
	for player in Charas.get_children():
		player.intended_action = Callable(Global, "empty_function")
	
	BAK.disabled = true
	
	current_turn = 0
	current_round += 1

# technically a signal function... to change the info when for focus and mouse_entering
func button_info(new_info: String) -> void:
	ActionInfo.text = new_info

func initiate_select_enemy() -> void:
	
	if Enemies.get_child_count() > 1:
		var selector = ENEMY_SELECTION.instantiate()
		selector.text = ''
		selector.info = current_enemy.name
		selector.connect("pressed", select_enemy)
		selector.call_deferred("grab_focus")
		
		current_enemy = Enemies.get_child(0)
		current_enemy.add_child(selector)
		
		turn = TURN_TYPE.SELECT_ENEMY
	else:
		current_player.action_victim = current_enemy
		player_pass_turn()

# whenever each character passes their turn (and for the final character pass)
func player_pass_turn() -> void:
	
	# check if the current player is the last in order
	# if: they are, end the turn
	# else: go to the next player and get their action
	
	if current_player == Charas.get_child(-1):
		# sets the TurnOrderPointMaster to the correct y position for the first point
		add_turn_order_point(0)
		
		# the actual ending turn part
		Animate.play("playerPassTurn")
	else:
		turn = TURN_TYPE.PLAYER
		# might be worth making a function for this cuz it gets call on passing turn too
		current_player = Charas.get_child(current_player.get_index() + 1)
		check_cost_all_actions(current_player.sprun_active)
		check_actions_visible(current_player.player_type)
		button_info(current_player.name + " probably has issues")
		BAK.disabled = true

## signal functions
func _on_bak_pressed() -> void:
	back_action.call()
func _on_atk_pressed() -> void:
	
	# the player's action is attack
	# if there's only one enemy, it just sets the victim to be that enemy
	# otherwise we need to select an enemy
	
	current_player.intended_action = Callable(current_player, "attack")
	initiate_select_enemy()
func _on_dfd_pressed() -> void:
	current_player.intended_action = Callable(current_player, "defend")
	player_pass_turn()
func _on_itm_pressed() -> void:
	current_player.intended_action = Callable(current_player, "focus")
	player_pass_turn()
func _on_big_atk_pressed() -> void:
	
	## ugghghghhghghghghghg big attack is an attack so it needs to select
	
	current_player.intended_action = Callable(current_player, "big_attack")
	initiate_select_enemy()
