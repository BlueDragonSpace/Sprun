extends Control

@export var visual_rotation = 0:
	set(new):
		self.rotation = new
		$Icon.rotation = -new
		# no matter what the Sprun's rotation is, the art will point upward
		
		visual_rotation = new

@export var active = false:
	set(new):
		match(new):
			false:
				modulate = Color(1.0, 1.0, 1.0, 0.318)
			true:
				modulate = Color(1.0, 1.0, 1.0, 1.0)
		active = new
