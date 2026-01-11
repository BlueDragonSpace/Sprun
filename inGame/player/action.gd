class_name Action
extends Resource



# Note that this does not contain the code for an action
# the action is added on inside of the script of each individual player

# This also does not contain the signal, that is more easily connected by a Node

@export var name: String = "action name" # word on the button
@export var func_name: String = 'in code name' # my stuff
# utilized to put the action into a folder, doesn't determine its function
enum ACTION_TYPE {ATTACK, DEFEND, SPRUN, OTHER}
@export var action_type = ACTION_TYPE.ATTACK
# must be one of these players to see the ability (also if used illegitamitely, does the empty function)
const PLAYER_TYPE = 'All, Basic, Wizerd, Kitty, Rodent Lord, Rat, Mouse, Hamster'
#@export_flags(PLAYER_TYPE) var player_type : int = 0
@export_custom(PROPERTY_HINT_FLAGS, PLAYER_TYPE) var player_type : int = 0
#@export var modifier: float = 1 # multiplies by a specific stat
@export var sprun_necessary: int = 0 # necessary to carry out the action
@export var sprun_loss: int = 0 #taken away upon use
@export var requires_target: bool = false # disables upon prep rounds
@export var button_info: String = 'button info' # hover over button

# also note that adding anything to here requires interpretation within player (and likely in the future enemy)
