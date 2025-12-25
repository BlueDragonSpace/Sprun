extends Button

# info for the info bar
@export var info: String = 'default text... uwu'

@onready var Root = get_tree().get_current_scene()

@export var sprun_cost = 0

func check_cost(sprun: int) -> void:
	if sprun >= sprun_cost:
		disabled = false
	else:
		disabled = true

func send_info() -> void:
	Root.button_info(info)

func _on_focus_entered() -> void:
	send_info()
func _on_mouse_entered() -> void:
	send_info()
