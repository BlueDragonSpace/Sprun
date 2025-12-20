extends Control

# I think imma do everything in a single script lol
# that's what I used to do... a long time ago


@onready var NoiseBackground: TextureRect = $NoiseBackground

@onready var Actions: HBoxContainer = $RootGame/LowerBar/Actions


## In-Battle
enum TURN_TYPE {INPUT, OUTPUT}
@export var turn = TURN_TYPE.INPUT:
	set(new):
		match(new):
			TURN_TYPE.INPUT:
				Actions.visible = true
			TURN_TYPE.OUTPUT:
				Actions.visible = false

var in_transition = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NoiseBackground.texture.noise.seed = randi()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	NoiseBackground.texture.noise.offset += Vector3(delta * 0.1, delta * 5, delta * 5)
	
	match(turn):
		TURN_TYPE.INPUT:
			pass
		TURN_TYPE.OUTPUT:
			pass

# signal functions
func _on_atk_pressed() -> void:
	# in reality it's a lot more complicated than this, but whatever
	if $RootGame/BattleScreen/Enemies/Enemy:
		$RootGame/BattleScreen/Enemies/Enemy.current_hp -= 8
