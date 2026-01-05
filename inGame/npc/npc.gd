extends Control

@onready var Root = get_tree().get_current_scene()

@onready var Icon: TextureRect = $VBoxContainer/Icon
@onready var HP: TextureProgressBar = $VBoxContainer/LowerBar/HP
@onready var CurrentHp: Label = $VBoxContainer/LowerBar/HP/HPBar/CurrentHP
@onready var MaxHp: Label = $VBoxContainer/LowerBar/HP/HPBar/MaxHP

@onready var Animate: AnimationPlayer = $Animate

# Character Icon
@export var icon = Image

# stats
@export var speed_stat : int = 12

@export var max_hp: int = 40
var current_hp: int = max_hp

@export var attack_stat : int = 3
@export var defend_stat : int = 5

# bad code: is it Npc or Character!
# and worst of all: Characters are contolled by Player, meaning that they are literal PCs instead of NPCs
enum CHARACTER_TYPE {ENEMY, PLAYER, NUHUH}
var npc_type = CHARACTER_TYPE.NUHUH # this class isn't intended to be used on it's own...

var current_defense : int = 0:
	set(new):
		if new <= 0:
			$VBoxContainer/LowerBar/Shield.visible = false
		else:
			$VBoxContainer/LowerBar/Shield.visible = true
		$VBoxContainer/LowerBar/Shield/ShieldNum.text = str(new)
		current_defense = new

var intended_action = Callable(Global, "empty_function")
var action_victim : Node

var is_dead = false
var size_transition = 0.0:
	set(new):
		size_transition = new
		size_flags_stretch_ratio = size_transition
		set_deferred("HP.size_flags_stretch_ratio", size_transition)

func _ready() -> void:
	set_max_hp(max_hp)
	Icon.texture = icon
	
	#size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_stretch_ratio = size_transition
	HP.size_flags_stretch_ratio = size_transition
	
	add_ready()
# this function is meant to be added on to the ready function, by children, so they don't have to redefine ready
func add_ready() -> void:
	pass

func _process(_delta) -> void:
	
	# wait a second I could just set this to a tween
	if HP.value > current_hp:
		visual_hp(int(HP.value) - 1)
	elif HP.value < current_hp:
		visual_hp(int(HP.value) + 1)

func visual_hp(new_hp : int) -> void:
	HP.value = new_hp
	CurrentHp.text = str(int(HP.value))

func set_max_hp(new_hp : int) -> void:
	
	max_hp = new_hp
	current_hp = new_hp
	visual_hp(new_hp)
	HP.max_value = new_hp
	MaxHp.text = str(new_hp)
#for some reason, if you call a Callable as a Callable, the function doesn't go through
func do_intended_action() -> void:
	current_defense = 0
	
	intended_action.call()
 
func take_damage(damage, attacker = null) -> void:
	if current_defense > 0:
		var undefended_damage = damage - current_defense
		current_defense = clamp(current_defense - damage, 0, INF)
		
		if undefended_damage > 0:
			current_hp -= undefended_damage
			Animate.play("take_hit")
		else:
			$DefendAttack.play()
	else:
		current_hp -= damage
		
	if current_hp <= 0:
		die()
	Animate.play("take_hit")
	
	if attacker != null:
		add_take_damage(attacker)

func add_take_damage(_attacker): # additional stuff I add to take_damage() in other classes (like enemy)
	pass

func defend():
	self.current_defense += defend_stat
	Animate.play("defend")
	$DoDefend.play()

func attack() -> void:
	if action_victim:
		action_victim.take_damage(attack_stat, self)
		Animate.play("attack")
		$Attack.play()


func die() -> void:
	# lol keep in mind the wizard's death is unique
	# just because I wanted to add a dumb sound
	
	# you can only die once
	if is_dead == false:
		is_dead = true
		Root.remove_dead_actions(self)
		Animate.call_deferred("play", "die")
	
	$Death.play()
