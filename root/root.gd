extends Control

# NodePathssssss
@onready var NoiseBackground: TextureRect = $NoiseBackground

@onready var Charas: VBoxContainer = $RootGame/BattleScreen/Charas
@onready var Enemies: GridContainer = $RootGame/BattleScreen/Enemies
@onready var TurnOrder: VBoxContainer = $RootGame/BattleScreen/TurnOrder/TurnOrder

@onready var Actions: TabContainer = $RootGame/LowerBar/VBoxContainer/Actions
@onready var IncreaseSprunSlots: Button = $RootGame/LowerBar/VBoxContainer/Actions/Sprun/IncreaseSprunSlots
@onready var ATKUp: Button = $RootGame/LowerBar/VBoxContainer/Actions/Sprun/ATKUp
@onready var DFDUp: Button = $RootGame/LowerBar/VBoxContainer/Actions/Sprun/DFDUp
@onready var SPDUp: Button = $RootGame/LowerBar/VBoxContainer/Actions/Sprun/SPDUp

@onready var BAK: Button = $RootGame/LowerBar/VBoxContainer/Actions/BackButton/BAK

@onready var LittlePlayerIcon: TextureRect = $RootGame/LowerBar/VBoxContainer/InfoBar/LittlePlayerIcon
@onready var ActionInfo: Label = $RootGame/LowerBar/VBoxContainer/InfoBar/ActionInfo
@onready var TWKPrepRoundsLabel: Label = $TWK/Labels/VBoxContainer/Num
@onready var TopBarPrepRoundsLabel: Label = $RootGame/TopBar/HBoxContainer/TextureRect/PrepRoundsLabel

@onready var Animate: AnimationPlayer = $Animate

var current_player = null:
	set(new):
		LittlePlayerIcon.texture = new.icon
		current_player = new
var current_enemy = null

const TURN_ORDER_POINT = preload("uid://kbdvggtyupd2") # current turn marker
const TURN_ORDER_MARKER = preload("uid://dim074qeqwx6x") # character/enemy order
const ENEMY_SELECTION = preload("uid://c6hsrr8o4xvi3")
## ENEMIES
const BIGG = preload("uid://bs8426h8sndoy")
const LITTLES = preload("uid://b6qpplfncfiyr")

@export var started : bool = false

## player section
var player_actions = []
## mid section
var mid_animation_action = func() : pass
var turn_order_data = [] # speed_stat, icon, node_path, action
var current_turn = 0
var current_wave = 0
## prep section
var in_prep_round = false
var prep_rounds_remaining = 3

## In-Battle
enum TURN_TYPE {PLAYER, SELECT_ENEMY, MIDDLE, END, TRANSITION}
@export var turn = TURN_TYPE.PLAYER:
	set(new):
		match(new):
			TURN_TYPE.PLAYER:
				# disabling
				disable_all_actions(false)
				BAK.disabled = true
				check_upgrade_cost_actions(current_player)
				check_cost_all_actions(current_player.sprun_active)
				if in_prep_round:
					disable_all_attacks(true)
				# visible (-ing)
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
				middle_round_loop()
			TURN_TYPE.END:
				BAK.disabled = true
				back_action = func(): Callable(Global, "empty_function")
				
			TURN_TYPE.TRANSITION:
				disable_all_actions(true)
				# it means that the Animate is going to middle, and right now
				# -it doesn't need to do anything else
		#print(new)
		turn = new


## Stats?
var enemies_slain = 0

var back_action = Callable(Global, "empty_function")

var in_transition = false
var current_round = 0:
	set(new):
		$RootGame/TopBar/HBoxContainer/RoundNum.text = str(new)
		current_round = new

# the player types, for use within the root, as an array rather than one string
var root_player_type_array = Action.PLAYER_TYPE.split(', ')

const to_player_text = ['Continue.', 'Escape.', 'Worth.', 'Catastrophe.', 'Perpetual.', 'Cycles.', 'The Hazy Abyss. They are there.']
const player_pass_text = [' looks a little agitated', ' probably needs some coffee', ' wonders why they are in the abyss', ' whistles', ' is quite tired of this nonsense', '.', ' doesn\'t really like all the rats']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_info("A last stand.")
	current_player = Charas.get_child(0)
	current_enemy = Enemies.get_child(0)
	
	BAK.disabled = true
	
	NoiseBackground.texture.noise.seed = randi()
	
	#IncreaseSprunSlots.sprun_cost = current_player.sprun_slots
	check_upgrade_cost_actions(current_player)
	
	call_deferred("set_turn_order")
	#check_cost_all_actions(current_player.sprun_active)
	call_deferred("check_cost_all_actions", current_player.sprun_active)
	#check_actions_visible(current_player.player_type)
	call_deferred("check_actions_visible", current_player.player_type)
	set_enemies_intents()
	
	Engine.time_scale = 1.0 # restarts for the top-right scale thing
	
	if started: 
		$RootGame.visible = true
		$RootGame.modulate.a = 1.0
		$IntroSequence.visible = false
	else:
		$RootGame.visible = false
		$RootGame.modulate.a = 0.0
		$IntroSequence.visible = true
		$IntroSequence.modulate.a = 1.0

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

## custom functions (other than signals) below

# helpers? I guess
func restart_tree() -> void:
	get_tree().reload_current_scene()

# real-deal hard deez nuts
func set_enemies_intents() -> void:
	for enemy in Enemies.get_children():
		if enemy.is_dead == false:
			enemy.intent = randi_range(0,0) #currently only sets to attack
			var tween = create_tween()
			# makes the Intent visible again
			# it's worth noting that "Intent" and "intent" are two completely separate things
				#I capitalize NodePaths, and make variables lowercase...
			tween.tween_property(enemy.Intent, "modulate", Color(1.0,1.0,1.0,1.0),1.0)
			
			# chooses a random target from all players
			enemy.set_intended_action(Charas.get_child(randi_range(0, Charas.get_child_count() - 1)))

func set_turn_order() -> void:
	## sorts the Turn Order
	
	# remove all children of turn ordering
	for child in TurnOrder.get_children():
		TurnOrder.remove_child(child)
		turn_order_data = []
	
	
	for enemy in Enemies.get_children():
		if enemy.is_dead == false:
			turn_order_data.push_back([enemy.speed_stat, enemy.Icon.texture, enemy, Callable(enemy, "do_intended_action")])
	# wonder if there is a such thing as a shared for loop..?
	for character in Charas.get_children():
		if character.is_dead == false:
			turn_order_data.push_back([character.speed_stat, character.Icon.texture,character, Callable(character, "do_intended_action")])
	
	#as it turns out, Godot's sort method will sort by the first element of each array in a nested array
	# which makes life a whole lot easier than doing custom_sort()
	turn_order_data.sort()
	
	for body in turn_order_data:
		var marker = TURN_ORDER_MARKER.instantiate()
		marker.texture = body[1]
		marker.self_modulate = body[2].Icon.self_modulate
		TurnOrder.add_child(marker)

func add_turn_order_point(point) -> void:
	var now_mark = TurnOrder.get_child(point)
	var new_turn_order_point = TURN_ORDER_POINT.instantiate()
	now_mark.add_child(new_turn_order_point)
	#temp_turn_order_point = new_turn_order_point

func select_enemy() -> void:
	
	current_player.action_victim = current_enemy
	current_enemy.get_child(-1).queue_free()
	
	player_pass_turn()

func add_enemy_wave() -> void:
	
	current_wave += 1
	$RootGame/TopBar/HBoxContainer/WaveNum.text = str(current_wave)
	
	
	
	
	########################### AAAAAAAAAAAAAAAAAAAAAAAAA
	
	
	match(randi_range(1, 1)):
		0:
			# one big 
			var big_boi = BIGG.instantiate()
			big_boi.name = 'BIGG'
			Enemies.add_child(big_boi)
			Enemies.columns = 1
		1:
			# many littles (4 - 6)
			for i in randi_range(4, 6):
				
				var little = LITTLES.instantiate()
				little.name = "Lytle " + str(i)
				# randomized stats are handled it its ready
				Enemies.add_child(little)
				
				little.Icon.self_modulate = Color(1 - i * 0.15, 1 - i * 0.15, 1 - i * 0.15) # makes each enemy darker
				
				Enemies.columns = 2
		2:
			# many littles
			pass
		_:
			print('unknown enemy wave value')
	
	# increases stats based on the wave number
	for enemy in Enemies.get_children():
		var mult = pow(1.3, current_wave - 1)
		#enemy.max_hp *= mult
		enemy.set_max_hp(enemy.max_hp * mult)
		enemy.attack_middle_value *= mult
		enemy.attack_stat *= mult
		enemy.defend_middle_value *= mult
		enemy.defend_stat *= mult
		

func disable_all_actions(boolean: bool) -> void:
	for container in Actions.get_children():
		for action in container.get_children():
			action.disabled = boolean

func disable_all_attacks(boolean: bool) -> void:
	for container in Actions.get_children():
		for action in container.get_children():
			if action.requires_target:
				action.disabled = boolean

func check_upgrade_cost_actions(character: Node) -> void:
	# intended for player, changes the cost of upgrade actions to be specific to player
	IncreaseSprunSlots.sprun_cost = character.sprun_slots
	ATKUp.sprun_cost = character.atk_upgrade_cost
	DFDUp.sprun_cost = character.dfd_upgrade_cost
	SPDUp.sprun_cost = character.spd_upgrade_cost

func check_cost_all_actions(sprun: int) -> void:
	# ends up disabling each action if you don't have the necessary sprun
	for container in Actions.get_children():
		for action in container.get_children():
			action.check_cost(sprun)

func check_actions_visible(player_type_bitwise: int) -> void:
	# now, for every action, check if it is available to the character
	for tab in Actions.get_children():
		for action in tab.get_children():
			
			action.visible = false
			
			if action.usable_on_player & 1: # if 'All' is set, it's gonna be visible
				action.visible = true
				continue
			
			#for bit in root_player_type_array.size(): # loops through every player type
				## if the action and the player have at least one of the same bit type, the action is visible (doesn't go through all bits?)
				#if action.usable_on_player & bit and player_type_bitwise & bit:
				## compares the two bit flags to each other,
				## potential downfall, when a character has two flags, would it mess up this system? idk
			if action.usable_on_player & player_type_bitwise != 0: 
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
			enemies_slain += 1
			$RootGame/TopBar/HBoxContainer/EnemiesSlainNum.text = str(enemies_slain)
			
			var total_wave_kill = true
			
			for loop in Enemies.get_child_count():
				if Enemies.get_child(loop).is_dead == false:
					total_wave_kill = false
					current_enemy = Enemies.get_child(loop)
					break
			
			if total_wave_kill:
				current_enemy = null
				TWKPrepRoundsLabel.text = str(prep_rounds_remaining - 1)
				# the prep_rounds_remaining is off by one at the start, to justify when it gets
				#-decreased whenever a round ends
				current_round += 1
				Animate.play("TWK")
				$TWK/Sounddddd.play()
			
		dead.CHARACTER_TYPE.PLAYER:
			
			var total_party_kill = true
			
			for loop in Charas.get_child_count():
				if Charas.get_child(loop).is_dead == false:
					total_party_kill = false
					current_player = Charas.get_child(loop)
					break
			
			if total_party_kill:
				Animate.play("TPK")
				$TPK/Soundd.play()

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
		
		current_player = Charas.get_child(current_player.get_index() + 1)
		turn = TURN_TYPE.PLAYER
		
		# chooses a random text from all player_pass_text's, and puts the current player's name in front of it
		button_info(current_player.name + player_pass_text[randi_range(0, player_pass_text.size() - 1)])
		BAK.disabled = true

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
	
	# chooses a random text from all the to_player_text's
	button_info(to_player_text[randi_range(0, to_player_text.size() - 1)])
	
	# removes the turn order point from the last child of the last npc in turn order
	var last_npc = TurnOrder.get_child(-1)
	if last_npc.get_child_count() > 0:
		last_npc.remove_child(last_npc.get_child(-1))
	
	for num in range(0, Charas.get_child_count()):
		if Charas.get_child(num).is_dead == false:
			current_player = Charas.get_child(num) # sets the current_player to be not dead
		break
	
	if in_prep_round:
		prep_rounds_remaining -= 1
		TopBarPrepRoundsLabel.text = str(prep_rounds_remaining)
		
		if prep_rounds_remaining <= 0:
			in_prep_round = false
			
			TopBarPrepRoundsLabel.text = 'X'
			disable_all_attacks(false)
			add_enemy_wave()
			current_enemy = Enemies.get_child(0)
			prep_rounds_remaining = randi_range(3, 4) # 2 or 3 prep rounds
			Animate.call_deferred("queue", "exiting_TWK")
	
	set_enemies_intents()
	set_turn_order()
	Animate.play("to_player")
	
	for player in Charas.get_children():
		player.intended_action = Callable(Global, "empty_function")
	
	$RootGame/NextRound.play()
	
	BAK.disabled = true
	
	current_turn = 0
	current_round += 1

## signal functions
# battle-game-turn-based stuff
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
func _on_focus_pressed() -> void:
	current_player.intended_action = Callable(current_player, "focus")
	player_pass_turn()
func _on_increase_sprun_slots_pressed() -> void:
	current_player.intended_action = Callable(current_player, "increase_sprun_slots")
	player_pass_turn()
func _on_atk_up_pressed() -> void:
	current_player.intended_action = Callable(current_player, "upgrade_atk")
	player_pass_turn()
func _on_dfd_up_pressed() -> void:
	current_player.intended_action = Callable(current_player, "upgrade_dfd")
	player_pass_turn()
func _on_spd_up_pressed() -> void:
	current_player.intended_action = Callable(current_player, "upgrade_spd")
	player_pass_turn()

func _on_itm_pressed() -> void:
	print("haven't set this up yet")
func _on_big_atk_pressed() -> void:
	current_player.intended_action = Callable(current_player, "big_attack")
	initiate_select_enemy()
func _on_pass_pressed() -> void:
	player_pass_turn()
func _on_masochism_pressed() -> void:
	current_player.current_hp -= 10
func _on_flash_evily_pressed() -> void:
	current_enemy.current_hp -= 10
func _on_auto_sprun_pressed() -> void:
	current_player.set_sprun(current_player.sprun_active + 1)
func _on_auto_heal_pressed() -> void:
	current_player.current_hp += 10

# actual real serious things
func _on_retry_pressed() -> void:
	Animate.play('retry')

func _on_start_button_pressed() -> void:
	Animate.play("start")
	$IntroSequence/AudioStreamPlayer.play()


func _on_play_speed_slider_value_changed(value: float) -> void:
	Engine.time_scale = value
