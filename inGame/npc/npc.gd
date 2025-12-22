extends Control

# non-tool
@onready var Icon: TextureRect = $VBoxContainer/Icon
@onready var HP: TextureProgressBar = $VBoxContainer/LowerBar/HP
@onready var CurrentHp: Label = $VBoxContainer/LowerBar/HP/HPBar/CurrentHP
@onready var MaxHp: Label = $VBoxContainer/LowerBar/HP/HPBar/MaxHP

# Character Icon
@export var icon = Image

# stats
@export var speedStat : int = 12

@export var max_hp: int = 40
var current_hp: int = max_hp

@export var attackStat : int = 3

var current_defense : int = 0:
	set(new):
		$VBoxContainer/LowerBar/Shield/ShieldNum.text = str(new)
		current_defense = new

var intended_action = Callable(self, "empty_function")
var action_victim : Node

func _ready() -> void:
	current_hp = max_hp
	visual_hp(current_hp)
	
	HP.max_value = max_hp
	MaxHp.text = str(max_hp)
	
	Icon.texture = icon
	
	add_ready()

# this function is meant to be added on to the ready function, by children, so they don't have to redefine ready
func add_ready() -> void:
	pass

func _process(_delta) -> void:
	
	if HP.value > current_hp:
		visual_hp(int(HP.value) - 1)
	elif HP.value < current_hp:
		visual_hp(int(HP.value) + 1)

func visual_hp(new_hp : int) -> void:
	HP.value = new_hp
	CurrentHp.text = str(int(HP.value))

#for some reason, if you call a Callable as a Callable, the function doesn't go through
func do_intended_action() -> void:
	intended_action.call()
