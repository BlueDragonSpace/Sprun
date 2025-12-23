extends "res://inGame/npc/npc.gd"

@export var sprun_slots = 8
@export_range(0, 360) var sprun_container_angle = 135
@export var sprun_distance = 0 ## wow that's pretty cool
const SPRUN = preload("uid://b6wgjet502thq")

@export var defendStat = 6

@onready var sprun_container: Control = $VBoxContainer/Icon/SprunContainer
@onready var Animate: AnimationPlayer = $Animate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in range(0, sprun_slots):
		var sprun = SPRUN.instantiate()
		
		sprun_container.add_child(sprun)
		
		sprun.pivot_offset.y += sprun_distance
		sprun.position.y -= sprun_distance
		@warning_ignore("integer_division")
		sprun.position -= Vector2(128 / 2, 128 / 2) # 128 comes from the Godot Sprite's original dimensions
		
		
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(45/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(-sprun_container_angle/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(slot * sprun_container_angle / (sprun_slots - 1))

# player has it's intended actions set by the Root (because it's from input from the UI)

func attack():
	action_victim.take_damage(attackStat)
	Animate.play("attack")

func defend():
	self.current_defense += defendStat
	Animate.play("defend")
