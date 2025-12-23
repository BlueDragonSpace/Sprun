extends "res://inGame/npc/npc.gd"

@onready var Intent: TextureRect = $VBoxContainer/Intent
@onready var IntentLabel: Label = $VBoxContainer/Intent/IntentLabel

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
	intent = INTENTS.ATTACK

func set_intended_action(victim: Node) -> void:
	# where the magic happens
	# by default, just attack
	intended_action = Callable(self, "attack")
	action_victim = victim

func attack():
	action_victim.take_damage(attackStat + random_offset)
	random_offset = 0
	speedStat = randi_range(1, 10)
	Animate.play("attack")
