extends Control

@onready var Icon: TextureRect = $VBoxContainer/Icon
@onready var HP: TextureProgressBar = $VBoxContainer/LowerBar/HP
@onready var CurrentHp: Label = $VBoxContainer/LowerBar/HP/HPBar/CurrentHP
@onready var MaxHp: Label = $VBoxContainer/LowerBar/HP/HPBar/MaxHP

# Character Icon
@export var icon = Image

# stats
@export var speed : int = 12

@export var max_hp: int = 40
var current_hp: int = max_hp

@export var attack : int = 3

var current_defense : int = 0

func _ready() -> void:
	HP.value = current_hp
	CurrentHp.text = str(int(HP.value))
	
	HP.max_value = max_hp
	MaxHp.text = str(max_hp)
	
	Icon.texture = icon

func _process(_delta) -> void:
	if HP.value > current_hp:
		HP.value -= 1
		
	elif HP.value < current_hp:
		HP.value += 1
