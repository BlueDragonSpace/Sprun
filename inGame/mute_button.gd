extends Button

const SOUND_ON = preload("uid://c25ehsvb06pmv")
const SOUND_OFF= preload("uid://bq520o0hbpclo")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mute_all_sound()


func _on_pressed() -> void:
	mute_all_sound()

func mute_all_sound() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)
	
	if button_pressed:
		icon = SOUND_OFF
	else:
		icon = SOUND_ON
