extends Control

@onready var NoiseBackground: TextureRect = $NoiseBackground
@onready var Actions: HBoxContainer = $RootGame/LowerBar/Actions
@onready var Animate: AnimationPlayer = $Animate

@onready var current_player = $RootGame/BattleScreen/Charas/Player
@onready var current_enemy = $RootGame/BattleScreen/Enemies/Enemy

@onready var Charas: VBoxContainer = $RootGame/BattleScreen/Charas
@onready var Enemies: VBoxContainer = $RootGame/BattleScreen/Enemies
@onready var TurnOrder: VBoxContainer = $RootGame/BattleScreen/TurnOrder/TurnOrder


const TURN_ORDER_MARKER = preload("uid://dim074qeqwx6x")

## player section
var player_actions = []
## mid section
var mid_animation_action = func() : pass
var turn_order_data = [] # speed_stat, icon, node_path, action
var current_turn = 0
## end section

## In-Battle
enum TURN_TYPE {PLAYER, MIDDLE, END}
@export var turn = TURN_TYPE.PLAYER:
	set(new):
		match(new):
			TURN_TYPE.MIDDLE:
				middle_round_loop() # could just call this method in Animate...
			TURN_TYPE.END:
				pass
				#current_player.current_defense = 0
			# SHOULD DO THE SAME FOR ENEMY (SORRY FOR CAPSLOCK)
		turn = new

var in_transition = false
var current_round = 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NoiseBackground.texture.noise.seed = randi()
	call_deferred("set_turn_order")

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


func middle_animation_constant() -> void:
	# constant, in the sense that this function is constant, while the mid animation action is not
	mid_animation_action.call()
	mid_animation_action = func(): pass #resets the action to be nothing afterward
	#intended for use with lambda functions, in the middle of an animation

func set_enemies_intents() -> void:
	for enemy in Enemies.get_children():
		enemy.intent = randi_range(0,0) #currently only sets to attack
		var tween = create_tween()
		# makes the Intent visible again
		# it's worth noting that "Intent" and "intent" are two completely separate things
			#I capitalize NodePaths, and make variables lowercase...
		tween.tween_property(enemy.Intent, "modulate", Color(1.0,1.0,1.0,1.0),1.0)
		
		enemy.set_intended_action()

func set_turn_order() -> void:
	## sorts the Turn Order
	
	# remove all children of turn ordering
	for child in TurnOrder.get_children():
		TurnOrder.remove_child(child)
		turn_order_data = []
	
	
	for enemy in Enemies.get_children():
		turn_order_data.push_back([enemy.speedStat, enemy.Icon.texture, enemy, enemy.intended_action])
	# wonder if there is a such thing as a shared for loop..?
	for character in Charas.get_children():
		turn_order_data.push_back([character.speedStat, character.Icon.texture,character, character.intended_action])
	
	#as it turns out, Godot's sort method will sort by the first element of each array in a nested array
	# which makes life a whole lot easier than doing custom_sort()
	turn_order_data.sort()
	
	for body in turn_order_data:
		var marker = TURN_ORDER_MARKER.instantiate()
		marker.texture = body[1]
		TurnOrder.add_child(marker)

func middle_round_loop() -> void:
	if current_turn < turn_order_data.size():
		mid_animation_action = turn_order_data[current_turn][3]
		current_turn += 1
		Animate.play("middle_round")
	else:
		current_turn = TURN_TYPE.END
		
		current_player.current_defense = 0
		current_turn = 0
		current_round += 1
		
		Animate.play("to_player")
		
## signal functions
func _on_atk_pressed() -> void:
	# in reality it's a lot more complicated than this, but whatever
	$RootGame/BattleScreen/Charas/Player.intended_action = func() : print('player actin') current_enemy.current_hp -= 8
	
	player_pass_turn()
func _on_dfd_pressed() -> void:
	$RootGame/BattleScreen/Charas/Player.current_defense += 6
	player_pass_turn()
func _on_itm_pressed() -> void:
	player_pass_turn()

# animation-only functions
func player_pass_turn() -> void:
	Animate.play("playerPassTurn")

#func animate_to_enemy() -> void:
	#current_enemy.Animate.play("attack")
	##Animate.play("enemyAttack")

func final_pass_turn() -> void:
	set_enemies_intents()
	set_turn_order()
	Animate.play("to_player")
	current_turn = 0
