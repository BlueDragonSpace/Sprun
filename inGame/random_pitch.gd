extends AudioStreamPlayer

# randomizes the pitch just a little bit for the next play, by increments of .2
func rand_play() -> void:
	pitch_scale = randi_range(-2, 2) * 0.2 + 1
	play()
