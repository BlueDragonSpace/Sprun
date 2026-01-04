extends Button

# surprisingly, this thing isn't directly correlated in code with the 
# -Action class or Resource

# info for the info bar
@onready var Root = get_tree().get_current_scene()

@export var info: String = 'default text... uwu'
@export var sprun_cost = 0

@export_custom(PROPERTY_HINT_FLAGS, Action.PLAYER_TYPE) var usable_on_player: int = 0
@export var requires_target = false

func check_cost(sprun: int) -> void:
	if sprun >= sprun_cost:
		disabled = false
	else:
		disabled = true

func send_info() -> void:
	$Focus.play()
	Root.button_info(info)

func _on_focus_entered() -> void:
	send_info()
func _on_mouse_entered() -> void:
	send_info()


func _on_pressed() -> void:
	$Click.play()
