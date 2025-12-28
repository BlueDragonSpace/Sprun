extends Node

#const reallyGood : Object = {
	#fans : 3,
	#forces: "I can't rn sry",
	#worthless : "pinochio",
#}

# name, power, NodeSignal
@export var actions: Array[int]
@export_custom(PROPERTY_HINT_NONE, "suffix:wuh") var suffix: Array[int]

@export var import_thing : Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
