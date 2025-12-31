extends "res://inGame/npc/npc.gd"

@onready var Intent: TextureRect = $VBoxContainer/IntentBar/Intent
@onready var IntentLabel: Label = $VBoxContainer/IntentBar/Intent/IntentLabel
@onready var IntendedTargetIcon: TextureRect = $VBoxContainer/IntentBar/IntendedTargetIcon

var node_is_ready = false # a small get around for INTENTS.ATTACK
var last_attacker : Node = null # remembers the last player to attack it

#var random_offset : int = 0:
	#set(new):
		#IntentLabel.text = str(attack_stat + random_offset)
		#random_offset = new

enum INTENTS {ATTACK, DEFEND, HEAL, OTHER, UNKNOWN}
@export var intent: INTENTS:
	set(new):
		match(new):
			INTENTS.ATTACK:
				#set new art for attack (a sword, duh)
				attack_stat = randi_range(attack_middle_value - attack_range, attack_middle_value + attack_range)
				if node_is_ready:
					IntentLabel.text = str(attack_stat)
			_:
				pass
		intent = new

@export var hp_range = 5
@export var speed_middle_value = 3
@export var speed_range = 5
@export var attack_middle_value = 7
@export var attack_range = 2
# randi_range(middle_value + range, middle_value - range)


func add_ready() -> void:
	npc_type = CHARACTER_TYPE.ENEMY
	intent = INTENTS.ATTACK
	
	IntentLabel.text = str(attack_stat)
	node_is_ready = true
	
	set_max_hp(randi_range(max_hp - hp_range, max_hp + hp_range))

func add_take_damage(attacker) -> void:
	last_attacker = attacker

func set_intended_action(victim: Node) -> void:
	# where the magic happens
	# by default, just attack
	intended_action = Callable(self, "attack")
	
	if last_attacker != null:
		victim = last_attacker
		last_attacker = null
	
	IntendedTargetIcon.texture = victim.icon
	action_victim = victim
	

func attack() -> void:
	action_victim.take_damage(attack_stat, self)
	speed_stat = randi_range(speed_middle_value - speed_range, speed_middle_value + speed_range)
	Animate.play("attack")
