extends "res://inGame/npc/npc.gd"

@onready var Animate: AnimationPlayer = $Animate

@onready var Intent: TextureRect = $VBoxContainer/Intent
@onready var IntentLabel: Label = $VBoxContainer/Intent/IntentLabel

var random_offset : int = 0

enum INTENTS {ATTACK, DEFEND, HEAL, BUFF, DEBUFF, UNKNOWN}
@export var intent : INTENTS:
	set(new):
		match(new):
			INTENTS.ATTACK:
				random_offset = randi_range(-2, 3)
				#set new art for attack (a sword, duh)
				print(IntentLabel.text)
				IntentLabel.text = str(attackStat + random_offset)
			_:
				pass
		intent = new

func _ready() -> void:
	intent = INTENTS.ATTACK

func attack(victim: Node) -> void:
	victim.current_hp -= attackStat + random_offset
	random_offset = 0
