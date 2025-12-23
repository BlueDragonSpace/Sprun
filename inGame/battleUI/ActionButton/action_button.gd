extends Button

# info for the info bar
@export var info: String = 'default text... uwu'

@onready var root = get_tree().get_current_scene()

func send_info() -> void:
	root.button_info(info)

func _on_focus_entered() -> void:
	send_info()
func _on_mouse_entered() -> void:
	send_info()
