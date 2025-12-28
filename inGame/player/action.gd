class_name Action
extends Resource



# Note that this does not contain the code for an action
# the action is added on inside of the script of each individual player

# This also does not contain the signal, that is more easily connected by a Node

@export var name: String = "action name"
# utilized to put the action into a folder, doesn't determine its function
enum ACTION_TYPE {ATTACK, DEFEND, SPRUN, BUFF, DEBUFF, OTHER, PASS}
@export var action_type = ACTION_TYPE.ATTACK
@export var modifier: float = 1 # multiplies by a specific stat
@export var sprun_necessary: int = 0 # necessary to carry out the action
@export var sprun_loss: int = 0
@export var button_info: String = 'button info'
