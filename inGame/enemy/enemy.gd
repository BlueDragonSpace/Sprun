extends "res://inGame/npc/npc.gd"

enum INTENTS {ATTACK, DEFEND, HEAL, BUFF, DEBUFF, UNKNOWN}
@export var intent = INTENTS.ATTACK
