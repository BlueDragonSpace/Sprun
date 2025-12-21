extends Control

@onready var NoiseBackground: TextureRect = $NoiseBackground
@onready var Actions: HBoxContainer = $RootGame/LowerBar/Actions
@onready var Animate: AnimationPlayer = $Animate

@onready var current_player = $RootGame/BattleScreen/Charas/Player
@onready var current_enemy = $RootGame/BattleScreen/Enemies/Enemy
@onready var Charas: VBoxContainer = $RootGame/BattleScreen/Charas
@onready var Enemies: VBoxContainer = $RootGame/BattleScreen/Enemies


var mid_animation_action = func() : pass

## In-Battle
enum TURN_TYPE {PLAYER, PLAYER_PASS, ENEMY, ENEMY_PASS}
@export var turn = TURN_TYPE.PLAYER:
	set(new):
		match(new):
			TURN_TYPE.ENEMY_PASS:
				current_player.current_defense = 0
			# SHOULD DO THE SAME FOR ENEMY (SORRY FOR CAPSLOCK)
		turn = new

var in_transition = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NoiseBackground.texture.noise.seed = randi()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	NoiseBackground.texture.noise.offset += Vector3(delta * 0.1, delta * 5, delta * 5)
	
	match(turn):
		TURN_TYPE.ENEMY:
			match(current_enemy.intent):
				current_enemy.INTENTS.ATTACK:
					mid_animation_action = func(): current_enemy.attack(current_player)
					Animate.play("enemyAttack")


func middle_enemy_attack() -> void:
	
	mid_animation_action.call()
	mid_animation_action = func(): pass #resets the action to be nothing afterward
	#intended for use with lambda functions, in the middle of an animation

func set_enemies_intents() -> void:
	for enemy in Enemies.get_children():
		enemy.intent = randi_range(0,0) #currently only sets to attack
		var tween = create_tween()
		# makes the intent visible again
		tween.tween_property(enemy.Intent, "modulate", Color(1.0,1.0,1.0,1.0),1.0)

## signal functions
func _on_atk_pressed() -> void:
	# in reality it's a lot more complicated than this, but whatever
	if $RootGame/BattleScreen/Enemies/Enemy:
		$RootGame/BattleScreen/Enemies/Enemy.current_hp -= 8
		
	player_pass_turn()

func _on_dfd_pressed() -> void:
	$RootGame/BattleScreen/Charas/Player.current_defense += 6
	player_pass_turn()

func _on_itm_pressed() -> void:
	player_pass_turn()

# animation-only functions
func player_pass_turn() -> void:
	Animate.play("playerPassTurn")

func animate_to_enemy() -> void:
	current_enemy.Animate.play("attack")
	Animate.play("enemyAttack")

func enemy_pass_turn() -> void:
	set_enemies_intents()
	Animate.play("to_player")
