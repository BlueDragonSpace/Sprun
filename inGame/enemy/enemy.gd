extends "res://inGame/npc/npc.gd"

@onready var Intent: TextureRect = $VBoxContainer/IntentBar/Intent
@onready var IntentLabel: Label = $VBoxContainer/IntentBar/Intent/IntentLabel
@onready var IntendedTargetIcon: TextureRect = $VBoxContainer/IntentBar/IntendedTargetIcon

var last_attacker : Node = null # remembers the last player to attack it

var random_offset : int = 0:
	set(new):
		IntentLabel.text = str(attackStat + random_offset)
		random_offset = new

enum INTENTS {ATTACK, DEFEND, HEAL, BUFF, DEBUFF, UNKNOWN}
@export var intent : INTENTS:
	set(new):
		match(new):
			INTENTS.ATTACK:
				random_offset = randi_range(-2, 3)
				#set new art for attack (a sword, duh)
				IntentLabel.text = str(attackStat + random_offset)
			_:
				pass
		intent = new

func add_ready() -> void:
	npc_type = CHARACTER_TYPE.ENEMY
	intent = INTENTS.ATTACK

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
	action_victim.take_damage(attackStat + random_offset, self)
	random_offset = 0
	speedStat = randi_range(1, 10)
	Animate.play("attack")
