extends "res://inGame/npc/npc.gd"

## Tool testing
@export var sprun_slots = 8
@export_range(0, 360) var sprun_container_angle = 0
@export var sprun_distance = 0
const SPRUN = preload("uid://b6wgjet502thq")

@onready var sprun_container: Control = $VBoxContainer/Icon/SprunContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in range(0, sprun_slots):
		var sprun = SPRUN.instantiate()
		
		
		sprun_container.add_child(sprun)
		
		
		sprun.visual_rotation += deg_to_rad(45)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(-sprun_container_angle/2)
		@warning_ignore("integer_division")
		sprun.visual_rotation += deg_to_rad(slot * sprun_container_angle / (sprun_slots - 1))
		#
		#
		sprun.position -= sprun_container.position #why
		#
		#sprun.pivot_offset.y += sprun_distance
		#sprun.position.y -= sprun_distance
		#
		#pushMatrix();
		#translate(200,200);
		#//rotate(-90);
		#rotate(-spread/2);
		#rotate(i * spread / (rads-1));
		#ellipse(dis,0,10,10);
		#popMatrix();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
